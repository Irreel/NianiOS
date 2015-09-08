//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//  change the world

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate {
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = BGColor
        let navigationViewController = UINavigationController(rootViewController: WelcomeViewController())
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.window!.rootViewController = navigationViewController
        self.window!.makeKeyAndVisible()
        
//        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
//            if #available(iOS 8.0, *) {
//                let settings = UIUserNotificationSettings(forTypes: ([UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge]), categories: nil)
//                application.registerUserNotificationSettings(settings)
//                application.registerForRemoteNotifications()
//            }
//        } else {
//            application.registerForRemoteNotificationTypes([UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Badge])
//        }
        
        WeiboSDK.enableDebugMode(false)
        WeiboSDK.registerApp("4189056912")
        WXApi.registerApp("wx08fea299d0177c01")
        MobClick.startWithAppkey("54b48fa8fd98c59154000ff2")
        
        /* 极光推送 */
//        todo
//        APService.registerForRemoteNotificationTypes( 1 << 0 | 1 << 1 | 1 << 2, categories: nil)
//        APService.setupWithOption(launchOptions)
        
        let notiCenter = NSNotificationCenter.defaultCenter()
        notiCenter.addObserver(self, selector: "handleNetworkReceiveMsg:", name: kJPFNetworkDidReceiveMessageNotification, object: nil)
        
        /* DDLog */
        let formatter = Formatter()
        DDTTYLogger.sharedInstance().logFormatter = formatter
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.logLevel = .Verbose
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.magentaColor(), backgroundColor: nil, forFlag: .Info)
        
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
        
//        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        // 处理通知
        if launchOptions != nil {
            logInfo("\(launchOptions)")
            
            let dict = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
            
            if dict != nil {
//               handleReceiveRemoteNotification(dict!)
                
            }
        
        
        }
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
//        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("AppDeactive", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
        
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
//        vc5._addObserver()
        
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()

    }
    
    func applicationDidBecomeActive(application: UIApplication) {
//        NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        go {
            let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var newDeviceToken = SAReplace("\(deviceToken)", before: "<", after: "")
            newDeviceToken = SAReplace("\(newDeviceToken)", before: ">", after: "")
            newDeviceToken = SAReplace("\(newDeviceToken)", before: " ", after: "")
            Sa.setObject(newDeviceToken, forKey:"DeviceToken")
            Sa.synchronize()
        }
        
        /* 设置极光推送 */
        
        APService.registerDeviceToken(deviceToken)
        let cc = APService.registrationID()
        logInfo("\(cc)")
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        logError("\(error)")
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let s = url.scheme
        if s == "nian" {
            delay(1, closure: { () -> () in
                NSNotificationCenter.defaultCenter().postNotificationName("AppURL", object: "\(url)")
            })
            return true
        } else if s == "wb4189056912" {
            return WeiboSDK.handleOpenURL(url, delegate: self)
        }
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                    fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! NSDictionary
                        
        handleReceiveRemoteNotification(aps)
        /*    */
        APService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)

    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let s = url.scheme
        if s == "wb4189056912" {
            return WeiboSDK.handleOpenURL(url, delegate: self)
        }
        return true
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        let json = response.userInfo as NSDictionary
        let uidWeibo = json.stringAttributeForKey("uid")
        let token = json.stringAttributeForKey("access_token")
        if let uid = Int(uidWeibo) {
            NSNotificationCenter.defaultCenter().postNotificationName("weibo", object:[uid, token])
        }
    }
    
    /**
    处理在 app 打开的情况下，通过极光 TCP 推送来的消息
    
    :param: noti <#noti description#>
    */
    func handleNetworkReceiveMsg(noti: NSNotification) {
        logWarn("\(noti)")
        
//        let userInfo = noti.userInfo
//        let _content = (userInfo as! Dictionary<String, NSObject>)["content"]
//        
        
//        navTo_MEVC()
    }
    
    // 收到消息通知，
    func handleReceiveRemoteNotification(aps: NSDictionary) {
        let content = aps["alert"] as! NSString
        let badge = aps["badge"] as! NSInteger
        let sound = aps["sound"] as! NSString
        
        logVerbose("\(content) \(badge) \(sound)")
        
        navTo_MEVC()
    }
    
    /**
    到 tab[3] 对应的 VC， 即私信界面
    */
    func navTo_MEVC() {
        let navViewController = window?.rootViewController as! UINavigationController
        let welcomeVC = navViewController.viewControllers[0] as! WelcomeViewController
        welcomeVC.shouldNavToMe = true
        
        
        logWarn("\(navViewController.viewControllers)")
    }
    
}


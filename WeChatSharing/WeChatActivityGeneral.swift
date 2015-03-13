//
//  WeChatActivityGeneral.swift
//  SuperBoard
//
//  Created by Xuzi Zhou on 1/12/15.
//  Copyright (c) 2015 Xuzi Zhou. All rights reserved.
//

import UIKit

class WeChatActivityGeneral: UIActivity {
    var text:String?
    var url:NSURL?
    var image:UIImage?
    var isSessionScene = true
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        var req:SendMessageToWXReq!
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            for item in activityItems {
                if item is UIImage {
                    return true
                }
                if item is String {
                    return true
                }
                if item is NSURL {
                    return true
                }
            }
        }
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for item in activityItems {
            if item is UIImage {
                image = item as? UIImage
            }
            if item is String {
                text = item as? String
            }
            if item is NSURL {
                url = item as? NSURL
            }
        }
    }
    
    override func performActivity() {
        var req = SendMessageToWXReq()
        req.bText = false
        req.message = WXMediaMessage()
        if isSessionScene {
            req.scene = WXSceneSession.value
        } else {
            req.scene = WXSceneTimeline.value
        }
        
        var imageNew = UIImage(named: "nian")!
        var textNew = "念" as NSString
        var urlNew = NSURL(string: "http://nian.so")!
        if image != nil {
            imageNew = image!
        }
        if text != nil {
            textNew = text! as NSString
            if textNew.length > 30 {
                textNew = textNew.substringToIndex(30)
            }
        }
        if url != nil {
            urlNew = url!
        }
        
        // 缩略图
        var width = 240.0 as CGFloat
        var height = width*(imageNew.size.height)/(imageNew.size.width)
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        imageNew.drawInRect(CGRectMake(0, 0, width, height))
        req.message.setThumbImage(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()
        
        var webObject = WXWebpageObject()
        webObject.webpageUrl = urlNew.absoluteString?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        req.message.mediaObject = webObject
        req.message.title = textNew
        req.message.description = "「念」\n全宇宙最残酷的 App，\n每天更新才不会被停号。😱"
        WXApi.sendReq(req)
        self.activityDidFinish(true)
    }
}

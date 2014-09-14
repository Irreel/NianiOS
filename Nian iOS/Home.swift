//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController, UIApplicationDelegate{
    var myTabbar :UIView?
    var slider :UIView?
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var dot:UILabel!
    var timer:NSTimer?
    
    var MainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    let itemArray = ["关注","发现","念","消息","设置"]
    let imageArray = ["explore","bbs","dream","me","settings"]
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        initViewControllers()
    }
    
    override func viewDidAppear(animated: Bool) {
        noticeDot()
    }
    
    func noticeDot() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var noticenumber = SAPost("uid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/dot.php")
        self.dot.text = ""
        if noticenumber == "0" {
            dot.hidden = true
        }else{
            dot.hidden = false
            UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                self.dot.frame = CGRectMake(228, 8, 20, 17)
                }, completion: { (complete: Bool) in
                    UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                        self.dot.frame = CGRectMake(228, 10, 20, 15)
                        }, completion: { (complete: Bool) in
                            self.dot.text = noticenumber
                    })
            })
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.dot.hidden = true
    }
    
    func setupViews()
    {
        self.automaticallyAdjustsScrollViewInsets = false
        
        //标题
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "念"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamButton")
        rightButton.image = UIImage(named:"add")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        //总的
        self.view.backgroundColor = BGColor
        self.tabBar.hidden = true
        var width = self.view.frame.size.width  //宽度
        var height = self.view.frame.size.height - 64   //高度
        
        //底部
        self.myTabbar = UIView(frame: CGRectMake(0,height-49,width,49)) //x，y，宽度，高度
        self.myTabbar!.backgroundColor = BarColor  //底部的背景色
        self.view.addSubview(self.myTabbar!)
        
        //底部按钮
        var count = self.itemArray.count
        for var index = 0; index < count; index++ {
            var btnWidth = (CGFloat)(index*64)
            var button  = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            button.frame = CGRectMake(btnWidth, 1,64,49)
            button.tag = index+100
            var image = self.imageArray[index]
            let myImage = UIImage(named:"\(image).png")
            let myImage2 = SAColorImg(UIColor.blackColor())
            
            button.setImage(myImage, forState: UIControlState.Normal)
            button.setBackgroundImage(myImage2, forState: UIControlState.Selected)
            
            button.clipsToBounds = true
            button.addTarget(self, action: "tabBarButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            self.myTabbar?.addSubview(button)
            if index == 2 {
                button.selected = true
            }
        }
        
        self.slider = UIView(frame:CGRectMake(128,46,64,3))
        self.slider!.backgroundColor = BlueColor
        self.myTabbar!.addSubview(self.slider!)
        
        
        
        
        self.dot = UILabel(frame: CGRectMake(228, 10, 20, 15))
        self.dot.textColor = UIColor.whiteColor()
        self.dot.font = UIFont.systemFontOfSize(10)
        self.dot.textAlignment = NSTextAlignment.Center
        self.dot.backgroundColor = BlueColor
        self.dot.layer.cornerRadius = 5
        self.dot.layer.masksToBounds = true
        noticeDot()
        self.myTabbar!.addSubview(dot!)
    }
    
    //每个按钮跳转到哪个页面
    func initViewControllers()
    {
        var NianStoryBoard:UIStoryboard = UIStoryboard(name: "NianViewController", bundle: nil)
        var NianViewController:UIViewController = NianStoryBoard.instantiateViewControllerWithIdentifier("NianViewController") as UIViewController
        
        
      //  var SettingsViewController:UIViewController = MainStoryBoard.instantiateViewControllerWithIdentifier("SettingsViewController") as UIViewController
        
        var vc1 = FollowViewController()
        var vc2 = ExploreController()
        var vc3 = NianViewController
        var vc4 = MeViewController()
        var vc5 = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.viewControllers = [vc1, vc2, vc3, vc4, vc5]
        self.customizableViewControllers = nil
    }
    
    
    //底部的按钮按下去
    func tabBarButtonClicked(sender:UIButton)
    {
        var index = sender.tag
        for var i = 0;i<5;i++ {
            var button = self.view.viewWithTag(i+100) as UIButton
            if button.tag == index{
                button.selected = true
            }else{
                button.selected = false
            }
        }
        UIView.animateWithDuration( 0.1,{
                self.slider!.frame = CGRectMake(CGFloat(index-100)*64,46,64,3)
            })
        self.selectedIndex = index-100
        
        //标题
            var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
            titleLabel.textColor = IconColor
            titleLabel.text = itemArray[index-100] as String
            titleLabel.textAlignment = NSTextAlignment.Center
            self.navigationItem.titleView = titleLabel
        
        
        if(index == 102){
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamButton")
            rightButton.image = UIImage(named:"add")
            self.navigationItem.rightBarButtonItem = rightButton
        }else if index == 103 {
            self.dot!.hidden = true
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func addDreamButton(){
        //var addDreamVC = AddDreamController()
        var NianVC = NianViewController()
      //  addDreamVC.delegate = NianVC    //😍
        var addDreamVC:UIViewController = MainStoryBoard.instantiateViewControllerWithIdentifier("AddDreamController") as UIViewController
        self.navigationController!.pushViewController(addDreamVC, animated: true)
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
}

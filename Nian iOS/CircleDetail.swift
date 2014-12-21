//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, editCircleDelegate{
    
    let identifier = "circledetailcell"
    let identifier2 = "circledetailtop"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var Id:String = "1"
    var navView:UIView!
    var topCell:CircleDetailTop!
    var circleData:NSDictionary?
    var textPercent:String = "-"
    var actionSheet:UIActionSheet?
    var actionSheetQuit:UIActionSheet?
    var cancelSheet:UIActionSheet?
    var addView:ILTranslucentView!
    var addStepView:CircleJoin!
    var theTag:Int = -2
    var thePrivate:String = ""
    var theLevel:Int = 0
    var editTitle:String = ""
    var editContent:String = ""
    var editImage:String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func setupViews()
    {
        viewBack(self)
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.blackColor()
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, globalWidth, 50))
        var nib = UINib(nibName:"CircleDetailCell", bundle: nil)
        var nib2 = UINib(nibName:"CircleDetailTop", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.tableView!)
        
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "梦境资料"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        Api.getCircleDetail(self.Id) { json in
            if json != nil {
                var arr = json!["items"] as NSArray
                var i = 0
                var cicleArray = json!["circle"] as NSArray
                self.circleData = cicleArray[0] as? NSDictionary
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                    var num = ((data as NSDictionary).objectForKey("num") as String).toInt()!
                    if num > 0 {
                        i++
                    }
                }
                var percent = Int(ceil(Double(i) / Double(self.dataArray.count) * 100))
                self.textPercent = "\(percent)%"
                self.tableView!.reloadData()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as CircleDetailTop
            var index = indexPath.row
            var dreamid = Id
            c.dreamid = dreamid
            if self.circleData != nil {
                self.thePrivate = self.circleData!.objectForKey("private") as String
                var textPrivate = ""
                if self.thePrivate == "0" {
                    textPrivate = "任何人都可加入"
                }else if self.thePrivate == "1" {
                    textPrivate = "需要验证后加入"
                }
                c.labelPrivate.text = textPrivate
                self.theTag = (self.circleData!.objectForKey("tag") as String).toInt()! - 1
                c.labelTag.text = V.Tags[self.theTag]
                c.numLeftNum.text = "\(self.dataArray.count)"
                c.numMiddleNum.text = self.textPercent
                self.editTitle = self.circleData!.objectForKey("title") as String
                c.nickLabel.text = self.editTitle
                self.editImage = self.circleData!.objectForKey("img") as String
                c.dreamhead.setImage("http://img.nian.so/dream/\(self.editImage)!dream", placeHolder: IconColor)
                var isJoin = self.circleData!.objectForKey("isJoin") as String
                if isJoin == "1" {
                    c.btnMain.setTitle("邀请", forState: UIControlState.Normal)
                    c.btnMain.hidden = false
                    var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "onCircleDetailMoreClick")
                    rightButton.image = UIImage(named:"more")
                    self.navigationItem.rightBarButtonItem = rightButton
                }else{
                    c.btnMain.setTitle("加入", forState: UIControlState.Normal)
                    c.btnMain.addTarget(self, action: "onCircleJoinClick", forControlEvents: UIControlEvents.TouchUpInside)
                    c.btnMain.hidden = false
                }
                self.editContent = self.circleData!.objectForKey("content") as String
                var textContent = ""
                if self.editContent == "" {
                    textContent = "暂无简介"
                }else{
                    textContent = self.editContent
                }
                c.labelDes.text = textContent
                var desHeight = textContent.stringHeightWith(12,width:200)
                c.labelDes.setHeight(desHeight)
                c.labelDes.setY( 110 - desHeight / 2 )
            }
            self.topCell = c
            cell = c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as CircleDetailCell
            var index = indexPath.row
            c.data = self.dataArray[index] as NSDictionary
            c.imageUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
            if indexPath.row == 0 {
                c.viewLine.hidden = true
            }else{
                c.viewLine.hidden = false
            }
            cell = c
        }
        return cell
    }
    
    func onCircleJoinClick(){
        self.addView = ILTranslucentView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        self.addView.translucentAlpha = 1
        self.addView.translucentStyle = UIBarStyle.Default
        self.addView.translucentTintColor = UIColor.clearColor()
        self.addView.backgroundColor = UIColor.clearColor()
        self.addView.alpha = 0
        self.addView.center = CGPointMake(globalWidth/2, globalHeight/2)
        var Tap = UITapGestureRecognizer(target: self, action: "onAddViewClick")
        Tap.delegate = self
        self.addView.addGestureRecognizer(Tap)
        
        var nib = NSBundle.mainBundle().loadNibNamed("CircleJoin", owner: self, options: nil) as NSArray
        self.addStepView = nib.objectAtIndex(0) as CircleJoin
        self.addStepView.circleID = self.Id
        self.addStepView.hashTag = self.theTag + 1
        self.addStepView.thePrivate = self.thePrivate
        self.addStepView.setX(globalWidth/2-140)
        self.addStepView.setY(globalHeight/2-106)
        self.addStepView.btnCancel.addTarget(self, action: "onCloseConfirm", forControlEvents: UIControlEvents.TouchUpInside)
        self.addView.addSubview(self.addStepView)
        
        self.view.addSubview(self.addView)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addView.alpha = 1
        })
    }
    
    func onViewCloseClick(){
        self.addStepView.textView.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var newTransform = CGAffineTransformScale(self.addView.transform, 1.2, 1.2)
            self.addView.transform = newTransform
            self.addView.alpha = 0
            }) { (Bool) -> Void in
                self.addView.removeFromSuperview()
        }
    }
    
    func onCloseConfirm(){
        if (self.addStepView.textView.text != "我想加入这个梦境！") & (self.addStepView.textView.text != "") {
            self.addStepView.textView.resignFirstResponder()
            self.cancelSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.cancelSheet!.addButtonWithTitle("不写了")
            self.cancelSheet!.addButtonWithTitle("继续写")
            self.cancelSheet!.cancelButtonIndex = 1
            self.cancelSheet!.showInView(self.view)
        }else{
            self.onViewCloseClick()
        }
    }
    
    //如果点了边缘，收起键盘并取消焦点
    func onAddViewClick(){
        self.addStepView.textView.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addStepView.setY(globalHeight/2-106)
        })
        self.addStepView.textView.resignFirstResponder()
    }
    
    func onCircleDetailMoreClick(){
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.circleData != nil {
            self.theLevel = (self.circleData!.objectForKey("level") as String).toInt()!
            if self.theLevel == 9 {
                self.actionSheet!.addButtonWithTitle("编辑梦境资料")
                self.actionSheet!.addButtonWithTitle("解散梦境")
                self.actionSheet!.addButtonWithTitle("取消")
                self.actionSheet!.cancelButtonIndex = 2
            }else if self.theLevel == 8 {
                self.actionSheet!.addButtonWithTitle("编辑梦境资料")
                self.actionSheet!.addButtonWithTitle("取消")
                self.actionSheet!.cancelButtonIndex = 1
            }else{
                self.actionSheet!.addButtonWithTitle("退出梦境")
                self.actionSheet!.addButtonWithTitle("取消")
                self.actionSheet!.cancelButtonIndex = 1
            }
        }
        self.actionSheet!.showInView(self.view)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view.classForCoder) == "UITableViewCellContentView"  {
            return false
        }
        return true
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func findTableCell(view: UIView?) -> UIView? {
        for var v = view; v != nil; v = v!.superview {
            if v! is UITableViewCell {
                return v
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.section==0{
            return  495
        }else{
            var index = indexPath!.row
            var data = self.dataArray[index] as NSDictionary
            return  CircleDetailCell.cellHeightByData(data)
        }
    }
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.actionSheet {
            if self.theLevel == 9 {
                if buttonIndex == 0 {
                    self.circleEdit()
                }else if buttonIndex == 1 {
                    self.circleDelete()
                }
            }else if self.theLevel == 8 {
                if buttonIndex == 0 {
                    self.circleEdit()
                }
            }else{
                if buttonIndex == 0 {
                    self.circleQuit()
                }
            }
        }else if actionSheet == self.actionSheetQuit {
            if buttonIndex == 0 {
                Api.postCircleQuit(self.Id) {
                    json in
                    if json != nil {
                        globalWillCircleReload = 1
                        self.navigationController!.popToRootViewControllerAnimated(true)
                    }
                }
            }
        }else if actionSheet == self.cancelSheet {
            if buttonIndex == 0 {
                self.onViewCloseClick()
            }
        }
    }
    
    func circleEdit(){
        if circleData != nil {
            println("编辑梦境资料啦")
            var addcircleVC = AddCircleController(nibName: "AddCircle", bundle: nil)
            addcircleVC.isEdit = 1
            addcircleVC.editId = self.Id.toInt()!
            addcircleVC.editTitle = self.editTitle
            addcircleVC.editContent = self.editContent
            addcircleVC.editImage = self.editImage
            addcircleVC.editPrivate = self.thePrivate
            addcircleVC.delegate = self
            self.navigationController!.pushViewController(addcircleVC, animated: true)
        }
    }
    
    func circleDelete(){
        println("解散梦境了！")
    }
    
    func circleQuit(){
        self.actionSheetQuit = UIActionSheet(title: "再见了，梦境 #\(Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetQuit!.addButtonWithTitle("退出梦境")
        self.actionSheetQuit!.addButtonWithTitle("取消")
        self.actionSheetQuit!.cancelButtonIndex = 1
        self.actionSheetQuit!.showInView(self.view)
    }
    
    func editCircle(editPrivate: Int, editTitle: String, editDes: String, editImage: String) {
        self.editTitle = editTitle
        self.editContent = editDes
        self.editImage = editImage
        self.thePrivate = "\(editPrivate)"
        self.topCell.nickLabel.text = editTitle
        if editDes == "" {
            self.topCell.labelDes.text = "暂无简介"
        }else{
            self.topCell.labelDes.text = editDes
        }
        var textPrivate = ""
        if editPrivate == 0 {
            textPrivate = "任何人都可加入"
        }else if editPrivate == 1 {
            textPrivate = "需要验证后加入"
        }
        self.topCell.labelPrivate.text = textPrivate
        self.topCell.dreamhead.setImage("http://img.nian.so/dream/\(editImage)!dream", placeHolder: IconColor)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
}


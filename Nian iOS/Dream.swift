//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

// label 文字距边界为 4px
class NILabel: UILabel {
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = CGRectInset(bounds, 4, 0)
        
        return rect
    }
}

class DreamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, UIGestureRecognizerDelegate, editDreamDelegate, delegateSAStepCell{
    
    let identifier = "dream"
    let identifier2 = "dreamtop"
    let identifier3 = "comment"
    
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var deleteSheet:UIActionSheet?
    var ownerMoreSheet:UIActionSheet?
    var guestMoreSheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteDreamSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    var navView:UIView!
    var viewCoin: Popup!
    
    var dreamowner:Int = 0 //如果是0，就不是主人，是1就是主人
    
    var EditId:Int = 0
    var EditContent:String = ""
    var ReplyUser:String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReturnReplyRow:Int = 0
    var ReplyCid:String = ""
    var activityViewController:UIActivityViewController?
    
    var ReturnReplyContent:String = ""
    var ReturnReplyId:String = ""
    
    var titleJson: String = ""
    var percentJson: String = ""
    var followJson: String = ""
    var likeJson: String = ""
    var imgJson: String = ""
    var privateJson: String = ""
    var contentJson: String = ""
    var owneruid: String = ""
    var likedreamJson: String = ""
    var likestepJson: String = ""
    var liketotalJson: Int = 0
    var stepJson: String = ""
    var tagArray: Array<String> = []  // 加 tag
    var loadTopCellDone: Bool = false
    
    var desHeight: CGFloat = 0
    
    var cacheTopCellHeight: CGFloat = 0.0   // 预先计算的 top cell 的高度
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    var topCell:DreamCellTop!
    var userImageURL:String = "0"
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //缺少这一句，会导致 UIScrollview 出现莫名其妙的偏移
        //https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/TransitionGuide.pdf
        self.automaticallyAdjustsScrollViewInsets = false
        
        setupViews()
        setupRefresh()
        SALoadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ShareContent", object:nil)
        self.loadTopCellDone = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ShareContent:", name: "ShareContent", object: nil)
        self.viewBackFix()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
    }

    func ShareContent(noti:NSNotification){
        var content:AnyObject = noti.object!
        var sid:Int = content[2] as! Int
        var row:Int = (content[3] as! Int)-10
        var url:NSURL = NSURL(string: "http://nian.so/m/step/\(sid)")!
        
        var customActivity = SAActivity()
        customActivity.saActivityTitle = "举报"
        customActivity.saActivityImage = UIImage(named: "flag")!
        customActivity.saActivityFunction = {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)", "http://nian.so/api/a.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        UIView.showAlertView("谢谢", message: "如果这个进展不合适，我们会将其移除。")
                    })
                }
            })
        }
        
        //编辑按钮
        var editActivity = SAActivity()
        editActivity.saActivityTitle = "编辑"
        editActivity.saActivityImage = UIImage(named: "edit")!
        editActivity.saActivityType = "编辑"
        editActivity.saActivityFunction = {
            self.activityViewController!.dismissViewControllerAnimated(true, completion: nil)
            var data = self.dataArray[row] as! NSDictionary
            var addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
            addstepVC.isEdit = 1
            addstepVC.data = data
            addstepVC.row = row
            addstepVC.delegate = self
            self.navigationController?.pushViewController(addstepVC, animated: true)
        }
        
        //删除按钮
        var deleteActivity = SAActivity()
        deleteActivity.saActivityTitle = "删除"
        deleteActivity.saActivityImage = UIImage(named: "goodbye")!
        deleteActivity.saActivityType = "删除"
        deleteActivity.saActivityFunction = {
            self.deleteId = sid
            self.deleteViewId = row
            self.deleteSheet = UIActionSheet(title: "再见了，进展 #\(sid)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.deleteSheet!.addButtonWithTitle("确定")
            self.deleteSheet!.addButtonWithTitle("取消")
            self.deleteSheet!.cancelButtonIndex = 1
            self.deleteSheet!.showInView(self.view)
        }
        
        var ActivityArray: Array<UIActivity>
        if self.dreamowner == 1 {
            ActivityArray = [ WeChatSessionActivity(), WeChatMomentsActivity(), deleteActivity, editActivity]
        } else {
            ActivityArray = [ WeChatSessionActivity(), WeChatMomentsActivity(), customActivity ]
        }
        var image = getCacheImage("\(content[1])")
        var arr = [content[0], url]
        if image != nil {
            arr.append(image!)
        }
        self.activityViewController = UIActivityViewController(activityItems: arr, applicationActivities: ActivityArray)
        self.activityViewController?.excludedActivityTypes = [
            UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
        ]
        self.presentViewController(self.activityViewController!, animated: true, completion: nil)
    }
    
    func shareDream(){
        var url:NSURL = NSURL(string: "http://nian.so/m/dream/\(self.Id)")!
        let activityViewController = UIActivityViewController(
            activityItems: [ "喜欢念上的这个记本！「\(self.titleJson)」", url ],
            applicationActivities: [WeChatSessionActivity(), WeChatMomentsActivity()])
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func setupViews() {
        self.viewBack()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"DreamCell", bundle: nil)
        var nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.tableView?.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        self.view.addSubview(self.tableView!)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
            self.tableView.headerBeginRefreshing()
        })
        
        //主人
        Api.getDreamTop(self.Id) { json in
            if json != nil {
                var dream: AnyObject! = (json!.objectForKey("data") as! Dictionary)["dream"]
                self.owneruid = dream.objectForKey("uid") as! String
                self.titleJson = SADecode(SADecode(dream.objectForKey("title") as! String))
                self.percentJson = dream.objectForKey("percent") as! String
                self.followJson = dream.objectForKey("follow") as! String
                self.likeJson = dream.objectForKey("like") as! String
                self.imgJson = dream.objectForKey("img") as! String
                self.privateJson = dream.objectForKey("private") as! String
                self.contentJson = SADecode(SADecode(dream.objectForKey("content") as! String))
                self.likedreamJson = dream.objectForKey("isliked") as! String
                self.likestepJson = dream.objectForKey("like_step") as! String
                self.liketotalJson =  self.likestepJson.toInt()!
                self.stepJson = dream.objectForKey("step") as! String
                self.tagArray = dream.objectForKey("tags") as! Array
                self.desHeight = self.contentJson.stringHeightWith(11, width:200)
                
                var Sa = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                
                if safeuid == self.owneruid {
                    self.dreamowner = 1
                    var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "ownerMore")
                    moreButton.image = UIImage(named:"more")
                    if self.privateJson != "2" {
                        self.navigationItem.rightBarButtonItems = [ moreButton]
                    }
                } else {
                    self.dreamowner = 0
                    var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "guestMore")
                    moreButton.image = UIImage(named:"more")
                    if self.privateJson == "0" {
                        self.navigationItem.rightBarButtonItems = [moreButton]
                    }
                }
                
                dispatch_after(2, dispatch_get_main_queue(), {
                    self.tableView.headerEndRefreshing(animated: true)
                    self.loadDreamTopcell()
                })
            }
        }
    }

    // 自定义 label 
    func labelWidthWithItsContent(label: NILabel, content: NSString) {
        var dict = [NSFontAttributeName: UIFont.systemFontOfSize(12)]
        var labelSize = CGSizeMake(ceil(content.sizeWithAttributes(dict).width), ceil(content.sizeWithAttributes(dict).height))
        
        label.numberOfLines = 1
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12)
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(red: 0xe6/255, green: 0xe6/255, blue: 0xe6/255, alpha: 1).CGColor
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        label.textColor = UIColor(red: 0x99/255, green: 0x99/255, blue: 0x99/255, alpha: 1)
        label.backgroundColor = UIColor.whiteColor()
        label.frame = CGRectMake(0, 0, labelSize.width + 16, 24)
    }
    
    
    func ownerMore(){
        self.ownerMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        self.ownerMoreSheet!.addButtonWithTitle("编辑记本")
        
        if self.percentJson == "1" {
            self.ownerMoreSheet!.addButtonWithTitle("还未完成记本")
        }else if self.percentJson == "0" {
            self.ownerMoreSheet!.addButtonWithTitle("完成记本")
        }
        
        self.ownerMoreSheet!.addButtonWithTitle("分享记本")
        self.ownerMoreSheet!.addButtonWithTitle("删除记本")
        self.ownerMoreSheet!.addButtonWithTitle("取消")
        self.ownerMoreSheet!.cancelButtonIndex = 4
        self.ownerMoreSheet!.showInView(self.view)
    }
    
    func guestMore(){
        self.guestMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        if self.followJson == "1" {
            self.guestMoreSheet!.addButtonWithTitle("取消关注记本")
        } else if self.followJson == "0" {
            self.guestMoreSheet!.addButtonWithTitle("关注记本")
        }
        
        if self.likedreamJson == "1" {
            self.guestMoreSheet!.addButtonWithTitle("取消赞")
        } else if self.likedreamJson == "0" {
            self.guestMoreSheet!.addButtonWithTitle("赞记本")
        }
        
        self.guestMoreSheet!.addButtonWithTitle("分享记本")
        self.guestMoreSheet!.addButtonWithTitle("标记为不合适")
        self.guestMoreSheet!.addButtonWithTitle("取消")
        self.guestMoreSheet!.cancelButtonIndex = 4
        self.guestMoreSheet!.showInView(self.view)
    }
    
    func SALoadData(clear: Bool = true){
        if clear {
            self.page = 0
        }
        self.tableView!.setFooterHidden(clear)
        Api.getDreamStep(self.Id, page: self.page) { json in
            if json != nil {
                var total = json!["total"] as! Int
                var thePrivate = json!["private"] as! String
                var uid = json!["uid"] as! String
                if total < 15 {
                    self.tableView!.setFooterHidden(true)
                }else{
                    self.tableView?.setFooterHidden(false)
                }
                var arr = json!["items"] as! NSArray
                if clear {
                    self.dataArray.removeAllObjects()
                }
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                if thePrivate == "2" {
                    // 删除
                    var viewTop = viewEmpty(globalWidth, content: "这个记本\n不见了")
                    viewTop.setY(104)
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    viewHolder.addSubview(viewTop)
                    self.view.addSubview(viewHolder)
                    self.tableView?.hidden = true
                    self.navigationItem.rightBarButtonItems = []
                }else if thePrivate == "1" && uid != safeuid {
                    // 私密
                    var viewTop = viewEmpty(globalWidth, content: "你发现了\n一个私密的记本\n里面记着什么？")
                    viewTop.setY(104)
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    viewHolder.addSubview(viewTop)
                    self.view.addSubview(viewHolder)
                    self.tableView?.hidden = true
                    self.navigationItem.rightBarButtonItems = []
                }else{
                    for data: AnyObject in arr {
                        self.dataArray.addObject(data)
                    }
                }
                self.tableView?.reloadData()
                self.tableView?.headerEndRefreshing()
                self.tableView?.footerEndRefreshing()
                self.page++
            }
        }
    }
    
    func onStepClick(){
        UIView.animateWithDuration(0.3, animations: {
            self.tableView!.contentOffset.y = 287
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section == 0 {
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as! DreamCellTop
            var index = indexPath.row
            var dreamid = Id
            c.dreamid = dreamid
            c.numMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onStepClick"))
            c.numLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeDream"))
            
            if (self.topCell != nil && self.topCell.scrollView.hidden == true) {
                c.moveUp()
            }
            self.topCell = c
            cell = c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.data = self.dataArray[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArray.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            var text = SADecode(SADecode(self.titleJson))
            if self.privateJson == "1" {
                text = "\(self.titleJson)（私密）"
            }else if self.percentJson == "1" {
                text = "\(self.titleJson)（已完成）"
            }
            
            if self.loadTopCellDone {
                self.cacheTopCellHeight = self.topCell.frame.size.height
                return self.topCell.frame.size.height
            } else if self.cacheTopCellHeight != 0.0 {
                return self.cacheTopCellHeight
            }
            
            return text.stringHeightBoldWith(19, width: 242) + 256 + 14 + 44
        }else{
            var data = self.dataArray[indexPath.row] as! NSDictionary
            var h = SAStepCell.cellHeightByData(data)
            return h
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    // 赞
    func onLikeTap(sender: UIButton) {
        var tag = sender.tag
        var data = self.dataArray[tag] as! NSDictionary
        if let numLike = data.stringAttributeForKey("like").toInt() {
            var numNew = numLike + 1
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setValue("\(numNew)", forKey: "like")
            mutableItem.setValue("1", forKey: "liked")
            self.dataArray.replaceObjectAtIndex(tag, withObject: mutableItem)
            self.tableView?.reloadData()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "1") { json in
            }
        }
    }
    
    // 取消赞
    func onLikedTap(sender: UIButton) {
        var tag = sender.tag
        var data = self.dataArray[tag] as! NSDictionary
        if let numLike = data.stringAttributeForKey("like").toInt() {
            var numNew = numLike - 1
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setValue("\(numNew)", forKey: "like")
            mutableItem.setValue("0", forKey: "liked")
            self.dataArray.replaceObjectAtIndex(tag, withObject: mutableItem)
            self.tableView?.reloadData()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "0") { json in
            }
        }
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view  = self.findTableCell(sender.view)!
        var img = dataArray[view.tag - 10].objectForKey("img") as! String
        var img0 = dataArray[view.tag - 10].objectForKey("img0") as! NSString
        var img1 = dataArray[view.tag - 10].objectForKey("img1") as! NSString
        var yPoint = sender.view!.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!)
        var w = CGFloat(img0.floatValue)
        var h = CGFloat(img1.floatValue)
        if w != 0 {
            h = h * globalWidth / w
            var rect = CGRectMake(-yPoint.x, -yPoint.y, globalWidth, h)
            if let v = sender.view as? UIImageView {
                v.showImage(V.urlStepImage(img, tag: .Large), rect: rect)
            }
        }
    }
    
    func findTableCell(view: UIView?) -> UIView? {
        for var v = view; v != nil; v = v!.superview {
            if v! is UITableViewCell {
                return v
            }
        }
        return nil
    }
    
    func onCommentClick(sender: UIGestureRecognizer) {
        var tag = sender.view!.tag
        var DreamCommentVC = DreamCommentViewController()
        DreamCommentVC.dreamID = self.Id.toInt()!
        DreamCommentVC.stepID = tag
        DreamCommentVC.dreamowner = self.dreamowner
        self.navigationController?.pushViewController(DreamCommentVC, animated: true)
    }
    
    func likeclick(sender: UITapGestureRecognizer) {
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(LikeVC, animated: true)
    }
    
    func userclick(sender: UITapGestureRecognizer) {
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func addStepButton(){
        var AddstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        AddstepVC.Id = self.Id
        AddstepVC.delegate = self    //😍
        self.navigationController?.pushViewController(AddstepVC, animated: true)
    }
    
    func countUp(coin: String, isfirst: String){
        self.SALoadData()
        var stepNum = self.topCell.numMiddleNum.text!.toInt()!
        self.topCell.numMiddleNum.text = "\(stepNum + 1)"
        if isfirst == "1" {
            self.viewCoin = (NSBundle.mainBundle().loadNibNamed("Popup", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Popup
            self.viewCoin.textTitle = "获得 \(coin) 念币"
            self.viewCoin.textContent = "你获得了念币奖励！"
            self.viewCoin.heightImage = 130
            self.viewCoin.textBtnMain = "好"
            self.viewCoin.btnMain.addTarget(self, action: "onCoinClick", forControlEvents: UIControlEvents.TouchUpInside)
            self.viewCoin.viewBackGround.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCoinClick"))
            self.viewCoin.viewHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
            var imageCoin = UIImageView(frame: CGRectMake(135 - 28, 55, 56, 70))
            imageCoin.image = UIImage(named: "coin")
            self.viewCoin.viewHolder.addSubview(imageCoin)
            self.view.addSubview(self.viewCoin)
        }
    }
    
    func onCoinClick() {
        self.viewCoin.removeFromSuperview()
    }
    
    func Editstep() {      //😍
        self.dataArray[self.editStepRow] = self.editStepData!
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.tableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SALoadData()
        })
        
        self.tableView!.addFooterWithCallback({
            self.SALoadData(clear: false)
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        
        if actionSheet == self.deleteSheet {
            if buttonIndex == 0 {
                var newpath = NSIndexPath(forRow: self.deleteViewId, inSection: 1)
                self.dataArray.removeObjectAtIndex(newpath!.row)
                self.tableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView!.reloadData()
                var stepNum = self.topCell.numMiddleNum.text!.toInt()!
                self.topCell.numMiddleNum.text = "\(stepNum - 1)"
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
                    if(sa == "1"){
                    }
                })
            }
        } else if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {       //删除记本
                self.navigationItem.rightBarButtonItems = buttonArray()
                globalWillNianReload = 1
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    Api.getDeleteDream(self.Id, callback: {
                        json in
                        var error = json!["error"] as! NSNumber
                        
                        if error == 0 {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.backNavigation()
                            })
                        } else {
                           self.navigationItem.rightBarButtonItems = []
                        }
                    })
                    
                    
                })
            }
        } else if actionSheet == self.ownerMoreSheet {
            if buttonIndex == 0 {   //编辑记本
                self.editMyDream()
            }else if buttonIndex == 1 { //完成记本
                var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "ownerMore")
                moreButton.image = UIImage(named:"more")
                if self.percentJson == "1" {
                    self.percentJson = "0"
                }else if self.percentJson == "0" {
                    self.percentJson = "1"
                }
                self.navigationItem.rightBarButtonItems = [ moreButton]
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&percent=\(self.percentJson)", "http://nian.so/api/dream_complete_query.php")
                    if sa != "" && sa != "err" {
                    }
                })
            }else if buttonIndex == 2 {     //分享记本
                shareDream()
            }else if buttonIndex == 3 {     //删除记本
                self.deleteDreamSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                self.deleteDreamSheet!.addButtonWithTitle("确定删除")
                self.deleteDreamSheet!.addButtonWithTitle("取消")
                self.deleteDreamSheet!.cancelButtonIndex = 1
                self.deleteDreamSheet!.showInView(self.view)
            }
        } else if actionSheet == self.guestMoreSheet {
            if buttonIndex == 0 {   //关注记本
                if self.followJson == "1" {
                    self.followJson = "0"
                }else if self.followJson == "0" {
                    self.followJson = "1"
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&fo=\(self.followJson)", "http://nian.so/api/dream_fo_query.php")
                    if sa != "" && sa != "err" {
                    }
                })
            } else if buttonIndex == 1 {     //赞记本
                onDreamLikeClick()
            } else if buttonIndex == 2 { //分享记本
                shareDream()
            } else if buttonIndex == 3 { //不合适
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/a.php")
                    if(sa == "1"){
                        dispatch_async(dispatch_get_main_queue(), {
                            UIView.showAlertView("谢谢", message: "如果这个记本不合适，我们会将其移除。")
                        })
                    }
                })
            }
        }
    }
    
    func editMyDream(readyForTag:Int = 0) {
        var editdreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        editdreamVC.delegate = self
        editdreamVC.isEdit = 1
        editdreamVC.editId = self.Id
        editdreamVC.editTitle = SADecode(SADecode(self.titleJson))
        editdreamVC.editContent = SADecode(SADecode(self.contentJson))
        editdreamVC.editImage = self.imgJson
        editdreamVC.editPrivate = self.privateJson
        editdreamVC.readyForTag = readyForTag
        editdreamVC.tagsArray = self.tagArray
        self.navigationController?.pushViewController(editdreamVC, animated: true)
    }
    
    func editDream(editPrivate:String, editTitle:String, editDes:String, editImage:String, editTag:String, editTags:Array<String>) {
        self.tagArray.removeAll(keepCapacity: false)
        
        self.topCell.scrollView.subviews.map({
            $0.removeFromSuperview()
        })
        self.topCell.scrollView.contentSize = CGSizeMake(8, self.topCell.scrollView.frame.height)
        
        self.titleJson = editTitle
        self.privateJson = editPrivate
        self.contentJson = editDes
        self.imgJson = editImage
        self.tagArray = editTags
        loadDreamTopcell()
    }

    func loadDreamTopcell() {
        var h: CGFloat = 0
        if self.privateJson == "1" {
            var _text = SADecode(SADecode(self.titleJson))
            var text = "\(_text)（私密）"
            var content = NSMutableAttributedString(string: text)
            var len = content.length
            content.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, len-4))
            content.addAttribute(NSForegroundColorAttributeName, value: SeaColor, range: NSMakeRange(len-4, 4))
            self.topCell.nickLabel.attributedText = content
            h = text.stringHeightBoldWith(19, width: 242)
        }else if self.percentJson == "1" {
            var _text = SADecode(SADecode(self.titleJson))
            var text = "\(_text)（已完成）"
            var content = NSMutableAttributedString(string: text)
            var len = content.length
            content.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, len-5))
            content.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(len-5, 5))
            self.topCell.nickLabel.attributedText = content
            h = text.stringHeightBoldWith(19, width: 242)
        }else{
            self.topCell.nickLabel.text = SADecode(SADecode(self.titleJson))
            h = self.titleJson.stringHeightBoldWith(19, width: 242)
        }
        
        var Sa = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        self.topCell.btnMain.hidden = false
        
        UIView.animateWithDuration(0.3, animations: {
            self.topCell.btnMain.alpha = 1
        })
        
        if self.owneruid == safeuid {
            self.topCell.btnMain.setTitle("更新", forState: UIControlState.Normal)
            self.topCell.btnMain.addTarget(self, action: "addStepButton", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            if self.likeJson == "0" {
                self.topCell.btnMain.setTitle("赞", forState: UIControlState.Normal)
                self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                self.topCell.btnMain.setTitle("分享", forState: UIControlState.Normal)
                self.topCell.btnMain.addTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        self.topCell.nickLabel.setHeight(h)
        var bottom = self.topCell.nickLabel.bottom()
        self.topCell.viewRight.setY(44)
        self.topCell.viewBG.setY(44)
        self.topCell.viewHolder.setY(bottom + 13)
        self.topCell.btnMain.setY(bottom + 128)
        self.topCell.dotLeft.setY(bottom + 181)
        self.topCell.dotRight.setY(bottom + 181)
        self.topCell.viewBG.setHeight(h + 256)
        self.topCell.viewLeft.setHeight(h + 256)
        self.topCell.viewRight.setHeight(h + 256)
        self.topCell.numLeftNum.text = "\(self.liketotalJson)"
        self.topCell.numMiddleNum.text = "\(self.stepJson)"
        
        if self.contentJson == "" {
            self.contentJson = "暂无简介"
        }
        self.topCell.labelDes.text = self.contentJson
        var desHeight = self.contentJson.stringHeightWith(12,width:200)
        self.topCell.labelDes.setHeight(desHeight)
        self.topCell.labelDes.setY( 110 - desHeight / 2 )
        self.userImageURL = "http://img.nian.so/dream/\(self.imgJson)!dream"
        self.topCell.dreamhead!.setImage(self.userImageURL, placeHolder: IconColor)
        self.topCell.dreamhead!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamHeadClick:"))
        
        if (count(self.tagArray) == 0 || (count(self.tagArray) == 1 && count(tagArray[0]) == 0)) {
            self.topCell.scrollView.hidden = true
            self.topCell.frame.size = CGSizeMake(self.topCell.frame.size.width, self.topCell.frame.size.height - 44)
            self.topCell.frame.origin = CGPointMake(self.topCell.frame.origin.x, self.topCell.frame.origin.y)
            self.loadTopCellDone = true
            self.tableView.reloadData()
        } else {
            self.topCell.scrollView.hidden = false
            
            for var i = 0; i < count(self.tagArray); i++ {
                var label = NILabel(frame: CGRectMake(0, 0, 0, 0))
                label.userInteractionEnabled = true
                label.text = self.tagArray[i] as String
                self.labelWidthWithItsContent(label, content: SADecode(self.tagArray[i]))
                label.frame.origin.x = self.topCell.scrollView.contentSize.width + 8
                label.frame.origin.y = 10
                label.tag = 12000 + i
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toSearch:"))
                self.topCell.scrollView.addSubview(label)
                self.topCell.scrollView.contentSize = CGSizeMake(self.topCell.scrollView.contentSize.width + 8 + label.frame.width , self.topCell.scrollView.frame.height)
            }
            
            self.topCell.scrollView.contentSize = CGSizeMake(self.topCell.scrollView.contentSize.width + CGFloat(16), self.topCell.scrollView.frame.height)
            self.topCell.scrollView.canCancelContentTouches = false
            self.topCell.scrollView.delaysContentTouches = false
            self.topCell.scrollView.userInteractionEnabled = true
            self.topCell.scrollView.exclusiveTouch = true
            
            self.loadTopCellDone = true
            self.tableView.reloadData()
        }
    }
    
    func onDreamHeadClick(sender: UIGestureRecognizer) {
        if let v = sender.view as? UIImageView {
            var yPoint = v.convertPoint(CGPointMake(0, 0), fromView: v.window!)
            var rect = CGRectMake(-yPoint.x, -yPoint.y, 60, 60)
            v.showImage("http://img.nian.so/dream/\(self.imgJson)!large", rect: rect)
        }
    }
    
    func toSearch(sender: UIGestureRecognizer) {
        let label = sender.view
        
        var storyboard = UIStoryboard(name: "Explore", bundle: nil)
        var searchVC = storyboard.instantiateViewControllerWithIdentifier("ExploreSearch") as! ExploreSearch
        searchVC.preSetSearch = self.tagArray[label!.tag - 12000]
        searchVC.shouldPerformSearch = true
        self.navigationController?.pushViewController(searchVC, animated: true)        
    }
    
    func likeDream() {
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 3
        self.navigationController?.pushViewController(LikeVC, animated: true)
    }
    
    func onDreamLikeClick() {
        if self.likedreamJson == "1" {
            self.likedreamJson = "0"
            self.topCell.btnMain.setTitle("赞", forState: UIControlState.Normal)
            self.topCell.btnMain.removeTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
            self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
            var numLike = self.topCell.numLeftNum.text!.toInt()!
            self.topCell.numLeftNum.text = (numLike > 0) ? "\(numLike - 1)" : "0"
        }else if self.likedreamJson == "0" {
            self.likedreamJson = "1"
            self.topCell.btnMain.setTitle("已赞", forState: UIControlState.Normal)
            self.topCell.btnMain.removeTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
            self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
            var numLike = self.topCell.numLeftNum.text!.toInt()!
            self.topCell.numLeftNum.text = "\(numLike + 1)"
        }
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&cool=\(self.likedreamJson)", "http://nian.so/api/dream_cool_query.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            var v = otherGestureRecognizer.view?.frame.origin.y
            if v > 0 {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            var v = otherGestureRecognizer.view?.frame.origin.y
            if v == 0 {
                return true
            }
        }
        return false
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArray, index, key, value, self.tableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 1, self.tableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArray, index, self.tableView, 1)
    }
    
}


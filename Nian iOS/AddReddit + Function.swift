//
//  AddReddit + Function.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension AddRedditController: DreamSelectedDelegate {
    func onImage() {
        self.dismissKeyboard()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func dreamSelected(id: String, title: String, content: String, image: String) {
        let v = (NSBundle.mainBundle().loadNibNamed("AddRedditDream", owner: self, options: nil) as NSArray).objectAtIndex(0) as! AddRedditDream
        v.title = title
        v.content = content
        v.image = "http://img.nian.so/dream/\(image)!dream"
        v.layoutSubviews()
        let image = getImageFromView(v)
        insertDream(image, dreamid: id)
    }
    
    func onDream() {
        let sb = UIStoryboard(name: "Explore", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("ExploreRecomMore") as! ExploreRecomMore
//        let viewController = storyboard.instantiateViewControllerWithIdentifier("CoinDetailViewController")
//        let vc2 = ExploreRecomMore()
        vc.titleOn = "插入记本"
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func uploadFile(image: UIImage) {
        
        let attachment = NSTextAttachment()
        let _image = resizedImage(image, newWidth: globalWidth - 32 - 4)
        attachment.image = _image
        attachment.bounds = CGRectMake(0, 0, _image.size.width, _image.size.height)
        let attStr = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: field2.attributedText)
        let selectedRange = field2.selectedRange
        mutableStr.insertAttributedString(attStr, atIndex: selectedRange.location)
        mutableStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSMakeRange(0,mutableStr.length))
        let newSelectedRange = NSMakeRange(selectedRange.location + 1, 0)
        field2.attributedText = mutableStr
        field2.selectedRange = newSelectedRange
        self.navigationItem.rightBarButtonItems = buttonArray()
        let uy = UpYun()
        uy.successBlocker = ({(data: AnyObject!) in
            let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "add")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton]
            var url = data.objectForKey("url") as! String
            url = SAReplace(url, before: "/bbs/", after: "<image:") as String
            url = "\(url)>"
            self.dict.setValue("\(url)", forKey: "\(attachment.image!)")
        })
        // todo: 下面的宽度要改成 500
        uy.uploadImage(resizedImage(attachment.image!, newWidth: 50), savekey: getSaveKey("bbs", png: "png") as String)
    }
    
    
    func insertDream(image: UIImage, dreamid: String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
        let attStr = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: field2.attributedText)
        let selectedRange = field2.selectedRange
        mutableStr.insertAttributedString(attStr, atIndex: selectedRange.location)
        mutableStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSMakeRange(0,mutableStr.length))
        let newSelectedRange = NSMakeRange(selectedRange.location + 1, 0)
        field2.attributedText = mutableStr
        field2.selectedRange = newSelectedRange
        self.dict.setValue("<dream:\(dreamid)>", forKey: "\(attachment.image!)")
    }
    
    func add() {
        var content = ""
        let range = NSMakeRange(0, field2.attributedText.length)
        field2.attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (dict, range, _) -> Void in
            if let d = dict["NSAttachment"] {
                let textAttachment = d as! NSTextAttachment
                let b = self.dict.stringAttributeForKey("\(textAttachment.image!)")
                content += b
            } else {
                let str = (self.field2.attributedText.string as NSString).substringWithRange(range)
                content += str
            }
        })
        print(content)
//        if isEdit == 1 {
//
//        }
//        let title = field1.text!
//        let content = field2.text!
//        let tags = tokenView.tokenTitles!
//        if title == "" {
//            self.view.showTipText("标题不能是空的...")
//            field1.becomeFirstResponder()
//        } else if content == "" {
//            self.view.showTipText("正文不能是空的...")
//            field2.becomeFirstResponder()
//        } else {
//            Api.postAddReddit(title, content: content, tags: tags) { json in
//                if json != nil {
//                    print(json)
//                }
//            }
//        }
    }
    
    func addDreamOK(){
        let title = self.field1?.text
        let content = self.field2.text
        let tags = self.tokenView.tokenTitles
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            //            title = SAEncode(SAHtml(title!))
            //            content = SAEncode(SAHtml(content!))
            Api.postAddDream(title!, content: content!, uploadUrl: self.uploadUrl, isPrivate: 0, tags: tags!) {
                json in
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        globalWillNianReload = 1
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }
        
    }
    
    //MARK: edit dream
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokenTitles
        var tagsString: String = ""
        var tagsArray: Array<String> = [String]()
        
        if (tags!).count > 0 {
            for i in 0...((tags!).count - 1){
                let tmpString = tags![i] as! String
                tagsArray.append(tmpString)
                if i == 0 {
                    tagsString = "tags[]=\(SAEncode(SAHtml(tmpString)))"
                } else {
                    tagsString = tagsString + "&&tags[]=\(SAEncode(SAHtml(tmpString)))"
                }
            }
        } else {
            tagsString = "tags[]="
        }
        
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            Api.postEditDream(self.editId, title: title!, content: content!, uploadUrl: self.uploadUrl, editPrivate: 0, tags: tagsString){
                json in
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    globalWillNianReload = 1
                    self.delegate?.editDream(0, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTags:tagsArray)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }
    }
    
//    func getImageHeight() -> CGFloat {
//        var h: CGFloat = 0
//        let range = NSMakeRange(0, field2.attributedText.length)
//        field2.attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (dict, range, _) -> Void in
//            if let d = dict["NSAttachment"] {
//                let textAttachment = d as! NSTextAttachment
//                let hNew = textAttachment.image!.size.height
//                h += hNew
//            }
//        })
//        return h
//    }
}
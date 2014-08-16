//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol AddStepDelegate {   //😍
    func countUp()
}

class AddstepController: UIViewController {
    
    @IBOutlet var TextView:UITextView
    @IBOutlet var Line: UIView
    @IBOutlet var uploadButton: UIButton?
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var uploadDone: UIImageView?
    var toggle:Int = 0
    var Id:String = ""
    var delegate: AddStepDelegate?      //😍
    
    @IBAction func uploadClick(sender: AnyObject) {
        if(toggle == 0){    //uploading
            self.uploadWait!.hidden = false
            self.uploadWait!.startAnimating()
            self.uploadDone!.hidden = true
            toggle = 1
        }else{      //done
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = false
            toggle = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        self.title = "新进展！"
        self.view.backgroundColor = BGColor
        self.TextView.backgroundColor = BGColor
        self.Line.backgroundColor = LineColor
        
        self.uploadWait!.hidden = true
        self.uploadDone!.hidden = true
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStep")
        rightButton.image = UIImage(named:"ok")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "新进展！"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func addStep(){
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var sa=SAPost("dream=\(Id)&&uid=1&&content=\(content)", "http://nian.so/api/addstep_query.php")
        if(sa == "1"){
            println("\(Id)")
            self.navigationController.popViewControllerAnimated(true)
            delegate?.countUp()
        }
    }
    
    func back(){
        self.navigationController.popViewControllerAnimated(true)
    }
    
    
    
    
}

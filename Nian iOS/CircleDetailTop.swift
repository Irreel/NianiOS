//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleDetailTop: UITableViewCell, UIGestureRecognizerDelegate{
    
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var dreamhead:UIImageView!
    @IBOutlet var View:UIView!
    @IBOutlet var labelDes:UILabel!
    @IBOutlet var btnMain:UIButton!
    @IBOutlet var viewRight:UIView!
    @IBOutlet var viewLeft:UIView!
    @IBOutlet var dotLeft:UIView!
    @IBOutlet var dotRight:UIView!
    
    @IBOutlet var numLeft:UIView!
    @IBOutlet var numMiddle:UIView!
    @IBOutlet var numLeftNum:UILabel!
    @IBOutlet var numMiddleNum:UILabel!
    @IBOutlet var viewLineLeft: UIView!
    
    @IBOutlet var labelTag: UILabel!
    @IBOutlet var labelPrivate: UILabel!
    
    var dreamid:String = ""
    var desHeight:CGFloat = 0
    var panStartPoint:CGPoint!
    var toggle:Int = 0
    var panGesture:UIGestureRecognizer!
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        self.panGesture.delegate = self
        self.View?.addGestureRecognizer(self.panGesture)
        self.btnMain.backgroundColor = SeaColor
        self.btnMain.hidden = true
        self.viewLeft.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
        self.viewRight.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.dreamhead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamHeadClick:"))
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }else{
            let panGesture = gestureRecognizer as UIPanGestureRecognizer
            let panY = panGesture.locationInView(self).y
            let translation = panGesture.translationInView(self)
            if panY > 287 {
                return false
            }else if fabs(translation.y) > fabs(translation.x) {  //如果是往下划
                return false
            }else{
                return true
            }
        }
    }
    
    func pan(pan:UIPanGestureRecognizer){
        var point = pan.locationInView(self.View)
        if pan.state == UIGestureRecognizerState.Began {
            panStartPoint = point
        }
        if pan.state == UIGestureRecognizerState.Changed {
            var distanceX = pan.translationInView(self.View!).x
            println(distanceX)
            self.View!.layer.removeAllAnimations()
            if self.toggle == 0 {
                var ratio:CGFloat = (distanceX > 0) ? 0.5 : 1
                self.viewLeft.frame.origin.x = distanceX * ratio
                self.viewRight.frame.origin.x = distanceX * ratio + 320
            }else{
                var ratio:CGFloat = (distanceX > 0) ? 1 : 0.5
                self.viewLeft.frame.origin.x = distanceX * ratio - 320
                self.viewRight.frame.origin.x = distanceX * ratio
            }
        }
        if pan.state == UIGestureRecognizerState.Ended {
            if panStartPoint.x > point.x {
                self.toggle = 1
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = -320
                    self.viewRight.frame.origin.x = 0
                    self.dotLeft.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
                    self.dotRight.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
                    }, completion: { (finished:Bool) -> Void in
                        if !finished {
                            return
                        }
                })
            }else{
                self.toggle = 0
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = 0
                    self.viewRight.frame.origin.x = 320
                    self.dotLeft.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
                    self.dotRight.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
                    }, completion: { (finished:Bool) -> Void in
                        if !finished {
                            return
                        }
                })
            }
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}

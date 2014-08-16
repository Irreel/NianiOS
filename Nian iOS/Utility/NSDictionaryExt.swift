//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation
extension NSDictionary {
   
    
    func stringAttributeForKey(key:String)->String
    {
        var obj : AnyObject! = self[key]
        if obj as NSObject == NSNull()
        {
            return ""
        }
        if obj.isKindOfClass(NSNumber)
        {
            var num = obj as NSNumber
            return num.stringValue
        }
       return obj as String
    }
    
}

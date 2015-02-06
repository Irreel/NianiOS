//
//  SQL.swift
//  Nian iOS
//
//  Created by Sa on 15/2/6.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

func SQLCircleListInsert(id: String, title: String, image: String, postdate: String) {
    // 插入梦境
    // id 创建的梦境编号
    // title 创建的梦境标题
    // image 创建的梦境封面路径
    // postdate 服务器返回的创建时间戳
    if let err = SD.executeChange("CREATE TABLE if not exists `circlelist` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `circleid` INT NOT NULL , `title` VARCHAR(255) NULL , `image` VARCHAR(255) NULL, `postdate` MEDIUMINT NOT NULL)") {
    }else{
        if let err2 = SD.executeChange("INSERT INTO circlelist (id, circleid, title, image, postdate) VALUES (null, ?, ?, ?, ?)", withArgs: [id, title, image, postdate]) {
        }
    }
}


func SQLCircleContent(id: String, uid: String, name: String, cid: String, cname: String, circle: String, content: String, title: String, type: String, time: String, isread: Int, callback: Void -> Void) {
    // 插入梦境聊天内容
    if let err = SD.executeChange("INSERT INTO circle (id, msgid, uid, name, cid, cname, circle, content, title, type, lastdate, isread) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgs: [id, uid, name, cid, cname, circle, content, title, type, time, isread]) {
    } else {
        callback()
    }
}


func SQLCircleContentTable(callback: Void -> Void) {
    // 创建梦境聊天内容表
    if let err = SD.executeChange("CREATE TABLE if not exists `circle` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `msgid` INT NOT NULL , `uid` INT NOT NULL , `name` VARCHAR(255) NULL , `cid` INT NOT NULL , `cname` VARCHAR(255) NULL , `circle` INT NOT NULL , `content` TEXT NULL , `title` VARCHAR(255) NULL , `type` INT NOT NULL , `lastdate` MEDIUMINT NOT NULL, `isread` INT NOT NULL)") {
    }else{
        callback()
    }
}
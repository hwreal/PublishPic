//
//  Network.swift
//  PublishPic
//
//  Created by hwreal on 2021/10/8.
//

import Foundation
import UIKit

// 上传图片到服务器,返回图片 url
func upload(image:UIImage,index: Int, callback: @escaping (String)->Void ){
    DispatchQueue.global().async {
        print("\(Date()): \(Thread.current)::  开始上传第 \(index) 张图片")
        let rand = arc4random() % 3 + 3
        sleep(rand)
        print("\(Date()):\(Thread.current)::  结束上传第 \(index) 张图片, 用时\(rand) 秒")
        let url = "https://xxx.com/\(index).png"
        callback(url)
    }
}

// 发布朋友圈
func publish(imageUrls:[String], text: String, callback:@escaping (Bool)->Void ){
    DispatchQueue.global().async {
        print("\(Date()): \(Thread.current)::  开始发布朋友圈: count:\(imageUrls.count)\n\(imageUrls)")
        let rand = arc4random() % 2 + 1
        sleep(rand)
        print("\(Date()): \(Thread.current)::  结束发布朋友圈, 用时\(rand) 秒")
        callback(true)
    }
}

func uploadPromise(image:UIImage,index: Int) -> Promise<String>{
    return Promise<String>.init { success, failure in
        upload(image: image, index: index) { url in
            success(url)
        }
    }
}

func publishPromise(imageUrls:[String], text: String) -> Promise<Bool>{
    return Promise<Bool>.init { success, failure in
        publish(imageUrls: imageUrls, text: text) { ret in
            success(ret)
        }
    }
}



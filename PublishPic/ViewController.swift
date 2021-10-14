//
//  ViewController.swift
//  PublishPic
//
//  Created by hwreal on 2021/10/8.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var images = {(1...20).map {_ in UIImage()}}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 先并发上传20张图片到图片服务器,全部返回url后再发布朋友圈, 使用5中方式发送
        
        //publishByGCDGroup()
        
        //publishByOperation()
       
        publishBySemaphore()
        
        //publishByPromise()
        
        //publishByYTK()
        
    }
    
    func publishByGCDGroup(){
        var imageUrls:[String?] = images.map { _ in nil }
        let lock = NSLock()
        
        
        let group = DispatchGroup()
        
        for (idx, img) in images.enumerated() {
            group.enter()
            upload(image: img, index: idx) { url in
                lock.lock()
                imageUrls[idx] = url
                lock.unlock()
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global()) {
            print("图片上传完毕")
            publish(imageUrls: imageUrls.compactMap{$0}, text: "hello") { ret in
                if ret{
                    print("朋友圈发布成功!!")
                }
            }
        }
    }
    
    
    func publishBySemaphore(){
        DispatchQueue.global().async {
            var imageUrls:[String?] = self.images.map { _ in nil }
            let sem = DispatchSemaphore(value: 0)
            let lock = NSLock()
            
            var completedUploadImageCount = 0
            for (idx, img) in self.images.enumerated() {
                upload(image: img, index: idx) { url in
                    lock.lock()
                    imageUrls[idx] = url
                    completedUploadImageCount += 1
                    if completedUploadImageCount == self.images.count {
                        sem.signal()
                    }
                    lock.unlock()
                }
            }
            
            sem.wait()
            print("图片上传完毕")
            publish(imageUrls: imageUrls.compactMap{$0}, text: "hello") { ret in
                if ret{
                    print("朋友圈发布成功!!")
                }
            }
        }
    }

    
    func publishByOperation(){
        var imageUrls:[String?] = images.map { _ in nil }
        let lock = NSLock()
        
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        
        let publishOperation = BlockOperation {
            print("图片上传完毕")
            publish(imageUrls: imageUrls.compactMap{$0}, text: "hello") { ret in
                if ret{
                    print("朋友圈发布成功!!")
                }
            }
        }
        
        for (idx, img) in images.enumerated() {
            let uploadOperation = BlockOperation {
                let sem = DispatchSemaphore(value: 0)
                upload(image: img, index: idx) { url in
                    lock.lock()
                    imageUrls[idx] = url
                    lock.unlock()
                    sem.signal()
                }
                sem.wait()
            }
            publishOperation.addDependency(uploadOperation)
            queue.addOperation(uploadOperation)
        }
        
        queue.addOperation(publishOperation)
    }
    
    func publishByPromise(){
        let uploadImagePromiseArr = images.enumerated().map{ (index, image) in
            uploadPromise(image: image, index: index)
        }
        
        Promise<[String]>
            .all(uploadImagePromiseArr)
            .flatMap { publishPromise(imageUrls: $0, text: "hello")}
            .then { ret in
                if ret {
                    print("朋友圈发布成功!!")
                }
            }
    }
    
    func publishByYTK(){
        
        YTKNetworkConfig.shared().baseUrl = "https://httpbin.org"
        
        let uploadImageApiArr = images.enumerated().map{ (index, image) -> UploadImageApi in
            UploadImageApi(image: image, index: UInt(index))
        }
        
        let batchReq = YTKBatchRequest(request: uploadImageApiArr)
        batchReq.startWithCompletionBlock { req in
            let reqArr = req.requestArray as! [UploadImageApi]
            let urls = reqArr.map{$0.imageUrl()}
            
            print("图片上传完毕")
            
            let publishCircleApi = PublishCircleApi(imageUrls: urls, text: "hello")
            publishCircleApi.startWithCompletionBlock { req in
                guard let data = req.responseData,
                      let str = String(data: data, encoding: .utf8)
                else {return}
                
                print("朋友圈发布成功!!\n\(str)")
            }
        }
    }
}

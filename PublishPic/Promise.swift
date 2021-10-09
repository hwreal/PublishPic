//
//  Promise.swift
//  hdy
//
//  Created by zhangqiyun on 2017/5/25.
//  Copyright © 2017年 hdy. All rights reserved.
//

import Foundation
import UIKit

enum PromiseStatus<Value> {
    case pending
    case processing
    case success(Value)
    case failure(Error)
}

public class Promise<Value> {
    typealias Success<Value> = (Value)->()
    fileprivate typealias Failure = (Error)->()
    var status:PromiseStatus<Value> = .pending
    fileprivate(set) var successQueue:[Success<Value>] = []
    fileprivate var failureQueue:[Failure] = []
    fileprivate var work:(@escaping Success<Value>, @escaping Failure) -> () = { _,_  in }
    public var value:Value? {
        if case .success(let value) = status {
            return value
        }
        else {
            return nil
        }
    }
    public var error:Error? {
        if case .failure(let error) = status {
            return error
        }
        else {
            return nil
        }
    }
    public init(_ work : @escaping(_ success: @escaping (Value) -> (), _ failure: @escaping (Error) -> ()) -> ()) {
        self.work = work
    }
    
    public convenience init(_ value:Value) {
        self.init { (success, _) in
            success(value)
        }
    }
    
    public convenience init(_ error:Error) {
        self.init { (_, failure) in
            failure(error)
        }
    }
    
    @discardableResult
    public func then(_ success:@escaping (Value) -> ()) -> Self {
        fire(success,nil)
        return self
    }
    
    @discardableResult
    public func `catch`(_ failure:@escaping (Error) -> ()) -> Self {
        fire(nil,failure)
        return self
    }
    
    public func map<NewValue>(transform:@escaping (Value)->(NewValue)) -> Promise<NewValue> {
        return Promise<NewValue>.init( {(success, failure) in
            self.fire({success(transform($0))}, failure)
        })
    }
    
    public func flatMap<NewValue>(transform:@escaping (Value)->Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue>.init( {(success, failure) in
            self.fire({transform($0).fire(success, failure)}, failure)
        })
    }
    
    public static func all<Value>(_ promises:[Promise<Value>]) -> Promise<[Value]> {
        return Promise<[Value]>.init({ (success, failure) in
            guard !promises.isEmpty else { success([]); return }
            promises.forEach({ (promise) in
                let success:Success<Value> = { _ in
                    if !promises.contains(where: {$0.value == nil}){
                        success(promises.compactMap{$0.value})
                    }
                }
                promise.fire(success, failure)
            })
        })
    }
    
    
    public static func all2<Value>(_ promises:[Promise<Value>]) -> Promise<[Value]> {
        return Promise<[Value]>.init { success, failure in
            guard !promises.isEmpty else {success([]); return}
            promises.forEach { promise in
                promise.then { v in
                    if !promises.contains(where: {$0.value == nil}){
                        success(promises.compactMap{$0.value})
                    }
                }.catch { e in
                    failure(e)
                }
            }
        }
    }
    
    
    public static func combine<T,U>(_ promiseA:Promise<T>,_ promiseB: Promise<U>) -> Promise<(T,U)> {
        return Promise<(T,U)>.init( { (success, failure) in
            promiseA.fire({ (a) in
                if let b = promiseB.value {
                    success((a,b))
                }
            }, failure)
            promiseB.fire({ (b) in
                if let a = promiseA.value {
                    success((a,b))
                }
            }, failure)
        })
    }
    
    fileprivate func fire(_ success: Success<Value>?, _ failure: Failure?) {
        if let success = success {
            successQueue.append(success)
        }
        if let failure = failure {
            failureQueue.append(failure)
        }
        switch status {
        case .success(let value):
            successQueue.forEach{$0(value)}
            successQueue.removeAll()
            failureQueue.removeAll()
        case .failure(let error):
            failureQueue.forEach{$0(error)}
            successQueue.removeAll()
            failureQueue.removeAll()
        case .pending:
            status = .processing
            work({(value) in
                self.status = .success(value)
                self.fire(nil,nil)
            }){(error) in
                self.status = .failure(error)
                self.fire(nil,nil)
            }
        case .processing:
            break
        }
    }
}

/*
public class CachePromise<Value>:Promise<Value> {
    private var identifier:String
    public init(identifier:String, work : @escaping(_ success: @escaping (Value) -> (), _ failure: @escaping (Error) -> ()) -> ()) {
        self.identifier = identifier
        super.init(work)
    }
    override public func map<NewValue>(transform:@escaping (Value)->(NewValue)) -> CachePromise<NewValue> {
        return CachePromise<NewValue>.init(identifier:identifier, work: {(success, failure) in
            self.fire({success(transform($0))}, failure)
        })
    }

}

public extension CachePromise where Value:Codable {
    @discardableResult
    public func cache(_ result:@escaping (Value?) -> ()) -> Self {
        let identifier = self.identifier
        successQueue.append{Cache.set($0, forKey: identifier)}
        Cache.get(for: identifier, result: result)
        return self
    }
}


public final class Cache {
    private static let cachePath:(String) -> String = { (key) in
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
        let fileName = "\(key).cache"
        let cachePath = cacheDirectory + "/" + fileName
        return cachePath
    }
    
    //存储缓存数据
    public static func set<T:Codable>(_ object: T, forKey key: String) {
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            NSKeyedArchiver.archiveRootObject(object.encoderData!, toFile: cachePath(key))
        })
    }
    
    //取缓存数据
    public static func get<T:Codable>(for key: String,result:@escaping (T?)->Void) {
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            let data = NSKeyedUnarchiver.unarchiveObject(withFile: cachePath(key)) as? Data
            DispatchQueue.main.async(execute: {() -> Void in
                guard let data = data else {
                    result(nil)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(T.self, from: data)
                    result(obj)
                } catch {
                    result(nil)
                }
            })
        })
    }
}

*/


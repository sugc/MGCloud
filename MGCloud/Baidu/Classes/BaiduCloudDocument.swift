//
//  BaiduCloudDocument.swift
//  MGCloud
//
//  Created by sugc on 2023/10/13.
//

import Foundation


class BaiduCloudDocument : CloudDocument {
    
    override func open(completionHandler: ((Bool) -> Void)? = nil) {
        //发起网络请求, 获取数据后
        
        //
        completionHandler?(true)
    }
    
    //保存到目标地址
    override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {        //预上传
        
        //判断url是否是一个百度云盘
        if url.cloundType() != .badidu {
            completionHandler?(false)
            return
        }
        
        //分割
        if saveOperation == .forCreating {
            create(to: url, completionHandler: completionHandler)
        }else {
            overwriting(to: url, completionHandler: completionHandler)
        }
        
        //合并
        
    }
    
    
    //创建文件
    func create(to url: URL, completionHandler: ((Bool) -> Void)? = nil) {        //预上传
       //判断文件是否存在
        
        
    }
    
    //覆写文件，是否创建不重要
    func overwriting(to url: URL, completionHandler: ((Bool) -> Void)? = nil) {        //预上传
        
        
    }
    
}

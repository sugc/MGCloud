//
//  CloudMetadataItem.swift
//  MGCloud
//
//  Created by sugc on 2023/10/13.
//

import Foundation
import CloudKit
//文件
public class CloudMetadataItem : Codable {
    
    public var url : URL!
    public var modifyTime : Date?
    public var createTime : Date?
    public var contentType : String = "public.item"
    public var name : String?
    public var extroInfo : Dictionary<String,String>?
    
    public init(){
        
    }
    public var path : String {
        get {
            return url.path
        }
    }
    
    public var size : Int = 0
    public var isDictionary : Bool {
        get {
            return (contentType == "public.folder" ||  contentType == "public.directory")
        }
    }
    
    public var dictionaryUrl : URL {
        if isDictionary {
            return url
        }
        
        return url.deletingLastPathComponent()
    }
    
//    var attribute : Dictionary<String, T>
    
    //文件夹才有
    public var subItems : Array<CloudMetadataItem>?
    
    public func isFileExist(at:URL)->Bool {
        //遍历查找
        if self.url == at {
            return true
        }
        
        guard let subItems = self.subItems else {
            return false
        }
        
        for item in subItems {
            if item.isFileExist(at: at) {
                return true
            }
        }
        return false
    }
    
   public func getItem(at:URL)->CloudMetadataItem? {
        if self.url == at {
            return self
        }
        
        guard let subItems = self.subItems else {
            return nil
        }
        
        for item in subItems {
            let res = item.getItem(at: at)
            if res != nil {
                return res
            }
        }
        
        return nil
    }
    
    func changeRootPath(rootPath:String) {
        var urlStr = (self.url.scheme ?? "") + "://" + (self.url.host ?? "")
        guard var curUrl = URL.init(string: urlStr) else {
            return
        }
        
        var coms = self.url.path.split(separator: "/")
        if !coms.first!.isEmpty {
            coms.removeFirst()
        }
    
    
        curUrl = curUrl.appendingPathComponent(rootPath)
        for item in coms {
            curUrl = curUrl.appendingPathComponent(String(item))
        }
        
        self.url = curUrl
        for item in self.subItems ?? [] {
            item.changeRootPath(rootPath: rootPath)
        }
        
    }
    
    //添加子项
    public func addSubItem(subItem:CloudMetadataItem)->Bool {
        if !self.isDictionary {
            return false
        }
        
        if subItem.url.deletingLastPathComponent().path == self.url.path {
            if self.subItems == nil {
                self.subItems = []
            }
            self.subItems?.append(subItem)
            return true
        }
        
        let subItems = self.subItems ?? []
        for i in 0..<subItems.count {
            let item = subItems[i]
            if item.url.path == subItem.url.path {
                self.subItems?[i] = subItem
                return true
            }
            
            if item.isDictionary && item.addSubItem(subItem: subItem) {
                return true
            }
        }
        
        
        if !self.url.path.hasPrefix(subItem.url.path) {
            return false
        }
        
        let subPath = subItem.path
        let remainPath = subPath.substring(from: subPath.index(subPath.startIndex, offsetBy: self.url.path.count))
        var pathComs = remainPath.split(separator: "/")
        pathComs.removeLast()
        
        var url = self.url!
        var curItem : CloudMetadataItem = self
        for com in pathComs {
            if com.isEmpty {
                continue
            }
            url = url.appendingPathComponent(String(com))
            let item = CloudMetadataItem()
            item.url = url
            item.createTime = subItem.createTime
            item.modifyTime = subItem.modifyTime
            item.contentType = "public.folder"
            curItem.addSubItem(subItem: item)
            curItem = item
        }
        curItem.addSubItem(subItem: subItem)
        
        return true
    }
    
    public func deleteSubItemAtUrl(url:URL)->Bool {
        if !self.isDictionary {
            return false
        }
        var hasFind = false
        self.subItems?.removeAll(where: { curItem in
            if curItem.url.path == url.path {
                hasFind = true
                return true
            }
            return false
        })
        
        if hasFind {
            return true
        }
        
        for item in self.subItems ?? [] {
            if item.isDictionary {
                if item.deleteSubItemAtUrl(url: url) {
                    return true
                }
            }
        }
        return false
    }
}
 
extension CloudMetadataItem {
    
    //获取所有的非文件夹的item
    public func getAllDataItems()->Array<CloudMetadataItem>! {
        
        var res : Array<CloudMetadataItem> = []
        
        if self.isDictionary {
            for sub in self.subItems ?? [] {
                res.append(contentsOf: sub.getAllDataItems())
            }
        }else {
            res.append(self)
        }
        return res
    }
    
}


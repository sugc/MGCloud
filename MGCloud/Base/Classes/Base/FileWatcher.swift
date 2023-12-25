//
//  FileWatcher.swift
//  CommonUtil
//
//  Created by sugc on 2023/7/15.
//


import Foundation

@objc protocol FileWatcherProtocol  {
    @objc optional func startWatching(fileURL: URL)
    @objc optional func stopWatching(fileURL: URL)
    
    func presentedItemDidChange(fileUrl:URL)
    
}

private class PrivateFilePresenter: NSObject, NSFilePresenter {
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue
    weak var watcher : FileWatcherProtocol?
    
    override init() {
        presentedItemOperationQueue = OperationQueue()
        super.init()
    }
    
    // 文件内容发生变化时调用
    func presentedItemDidChange() {
        // 在这里处理文件内容变化的逻辑
        print("文件内容已经发生变化")
        watcher?.presentedItemDidChange(fileUrl: presentedItemURL!)
    }
    
    // 开始监听文件内容变化
    func startWatching(fileURL: URL) {
        presentedItemURL = fileURL
        NSFileCoordinator.addFilePresenter(self)
    }
    
    // 停止监听文件内容变化
    func stopWatching() {
        NSFileCoordinator.removeFilePresenter(self)
        presentedItemURL = nil
    }
    
    func addObserverForUrl(observer:Any, url:URL) {
        
    }
    
    
}

//
public class FileWatcher: NSObject {
    
    var observerSet : Dictionary<URL,FileWatcherProtocol> = [:]
    
    override init() {
        super.init()
    }
    
    //添加监听
    func startWatchingForUrl(observer:FileWatcherProtocol, url:URL) {
        observerSet[url] = observer
        
    }
    
    func stopWatchingForUrl(observer:FileWatcherProtocol, url:URL) {
        
    }
    
    
}

// 使用示例
//let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
//let fileWatcher = FileWatcher()
//fileWatcher.startWatching(fileURL: fileURL)

// 当文件内容发生变化时，fileWatcher 的 presentedItemDidChange() 方法会被调用

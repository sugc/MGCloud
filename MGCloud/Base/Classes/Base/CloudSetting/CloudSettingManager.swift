//
//  CloudSettingManager.swift
//  MGCloud
//
//  Created by sugc on 2023/12/8.
//

import Foundation

let kCloudAllSettingsKey = "kCloudSettingsKey"
let kCloudSettingItemKey = "kCloudSettingItemKey"

public class CloudSettingManager {
    
    public static var shared = CloudSettingManager()
    public var currentCloudItem : CloudSettingItem!
    var settingItems : Array<CloudSettingItem> = []
    
    init() {
        settingItems = getSettingItems()
    }
    
    //获取所有本地设置
    func getSettingItems()->Array<CloudSettingItem>! {
        
        var defaultItems = defaultSettingItems()!
        let data = UserDefaults.standard.object(forKey: kCloudSettingItemKey) as? Data
        if data != nil {
            let item = CloudSettingItem.instanceFrom(data: data!)
            currentCloudItem = item ?? defaultItems.first
            
            for i in 0..<defaultItems.count {
                let curItem = defaultItems[i]
                if curItem.type == currentCloudItem.type {
                    defaultItems[i] = currentCloudItem
                }
            }
        }else {
            currentCloudItem = defaultItems.first
        }
        return defaultItems
    }
    
    //默认支持的设置
    func defaultSettingItems()->Array<CloudSettingItem>! {
        return [
            CloudSettingItem(type: .badidu,rootDic: "",token: "")
        ]
    }
    
    func saveCurrentSetting(item:CloudSettingItem){
        self.currentCloudItem = item
        UserDefaults.standard.set(self.currentCloudItem.toData(), forKey: kCloudSettingItemKey)
    }
    
    //展示设置页面
    public func showSettingViewControllerIfNeed(completion:((_ success:Bool, _ shouldRefresh:Bool)->Void)?) {
        
        if self.currentCloudItem.isValid() {
            completion?(true, false)
            return
        }
        
        self.showSettingViewController(completion: completion)
    }
    
    public func showSettingViewController(completion:((_ success:Bool, _ shouldRefresh:Bool)->Void)?) {
        let cloudSettingVC = CloudSettingViewController()
        cloudSettingVC.completion = completion
        let navi = UIApplication.shared.windows.first!.rootViewController as? UINavigationController
        navi?.pushViewController(cloudSettingVC, animated: true)
    }
}

//
//  CloudSettingViewController.swift
//  MGCloud
//
//  Created by sugc on 2023/12/6.
//

import Foundation
import MGUIKit




//添加云端信息的设置页面
// 云端类型
//存储的根目录



public class CloudSettingViewController : MGNavigaionViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var selectedItem : CloudSettingItem!
    var tableView : UITableView!
    var loginBtn : UIButton!
    var saveBtn : UIButton!
    
    var completion:((_ success:Bool, _ shouldRefresh:Bool)->Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedItem = CloudSettingManager.shared.currentCloudItem
        
        //读取基本信息，并展示 
        tableView = UITableView.init(frame: CGRect(x: 0,
                                                   y: self.navigationView.bottom,
                                                   width: view.width,
                                                   height: view.height - self.navigationView.bottom))
        tableView.register(CloudSettingTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(CloudSettingTableViewCell.classForCoder()))
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: tableView.width,
                                                              height: 60))
//        tableView.tableFooterView?.backgroundColor = .red
        
        loginBtn = UIButton.init(frame: CGRect(x: 0, y: 10, width: 80, height: 40))
        loginBtn.setTitle(cloudLocalizedString("登录"), for: .normal)
        loginBtn.setTitle(cloudLocalizedString("已登录"), for: .disabled)
        loginBtn.addTarget(self, action: #selector(actionLogin), for: .touchUpInside)
        loginBtn.backgroundColor = .black
        loginBtn.layer.cornerRadius = loginBtn.height / 2.0
        loginBtn.centerX = self.view.width / 4.0
        
        
        saveBtn = UIButton.init(frame: CGRect(x: 100, y: 10, width: 80, height: 40))
        saveBtn.setTitle(cloudLocalizedString("保存"), for: .normal)
        saveBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        saveBtn.backgroundColor = .black
        saveBtn.layer.cornerRadius = loginBtn.height / 2.0
        saveBtn.centerX = self.view.width / 4.0 * 3.0
        
        tableView.tableFooterView?.addSubview(loginBtn)
        tableView.tableFooterView?.addSubview(saveBtn)
        
        view.addSubview(tableView)
        
        checkBtnStatus()
    }
    
    public override func goBack() {
        super.goBack()
        self.completion?(CloudSettingManager.shared.currentCloudItem.isValid(), false)
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CloudSettingTableViewCell.classForCoder()), for: indexPath) as! CloudSettingTableViewCell
        
        var title = cloudLocalizedString("网络存储类型")
        var canEdit = false
        var content = selectedItem.cloudName()
        if indexPath.row == 1 {
            title = cloudLocalizedString("存储根目录")
            canEdit = true
            content = selectedItem.rootDic
        }
        
        weak var weakSelf = self
        cell.refresh(placeHoder: title,
                     content: content,
                     canEdit: canEdit,
                     callBack: { value in
            //回调
            if indexPath.row == 1 {
                weakSelf?.selectedItem.rootDic = value ?? ""
                weakSelf?.checkBtnStatus()
            }
        }, rightIcon: nil) { cell in
            //点击事件处理
        }
        return cell
    }
    

    //前往登录, 目前只支持百度
    @objc func actionLogin() {
        let loginVC = BaiduCloudAuthorizonViewController()
        weak var weakSelf = self
        loginVC.completion = { accessToken in
            weakSelf?.selectedItem.token = accessToken ?? ""
            weakSelf?.checkBtnStatus()
        }
        
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    //保存信息
    @objc func actionSave() {
        
        //判断根目录是否合法
        var rootDic = self.selectedItem.rootDic
        while(rootDic.hasPrefix(" ")) {
            rootDic = rootDic.substring(from:rootDic.index(rootDic.startIndex, offsetBy: 1) )
        }
        
        if(rootDic.hasPrefix("/")) {
            rootDic = rootDic.substring(from:rootDic.index(rootDic.startIndex, offsetBy: 1) )
        }
        
        while(rootDic.hasSuffix(" ") || rootDic.hasSuffix("/")) {
            rootDic = rootDic.substring(to: rootDic.index(rootDic.endIndex, offsetBy: -1))
        }
                
        if rootDic.isEmpty {
            MGLoading.showMessage(type: .failed, message: cloudLocalizedString("根目录不能为空"))
            return
        }
        
        if rootDic.contains("/") {
            MGLoading.showMessage(type: .failed, message: cloudLocalizedString("根目录必须为一级目录"))
            return
        }
       
        rootDic = "/" + rootDic
        
        var url = URL.init(string: "https://pan.baidu.com")!
        url = url.appendingPathComponent(rootDic)
        if url == nil {
            MGLoading.showMessage(type: .failed, message: cloudLocalizedString("根目录不合法，请重新输入"))
            return
        }
        
        self.selectedItem.rootDic = rootDic
        if self.selectedItem.token.isEmpty {
            MGLoading.showMessage(type: .failed, message: cloudLocalizedString("请先登录授权"))
            return
        }
        
        if self.selectedItem.token == CloudSettingManager.shared.currentCloudItem.token &&
            self.selectedItem.rootDic == CloudSettingManager.shared.currentCloudItem.rootDic {
            self.completion?(true,false)
            return
        }

        MGLoading.show()
        
        //原本就合法，修改文件根目录
        if  CloudSettingManager.shared.currentCloudItem.isValid() {
            CloudManager.sharedCloudManager().changeRootDic(rootDic: rootDic) { success in
                DispatchQueue.main.async {
                    MGLoading.stop()
                    if !success {
                        MGLoading.showMessage(type: .failed, message: cloudLocalizedString("保存失败，请重试"))
                        return
                    }
                    
                    MGLoading.showMessage(type: .success, message: cloudLocalizedString("保存成功"))
                    CloudSettingManager.shared.saveCurrentSetting(item: self.selectedItem)
                    self.completion?(true,true)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            return
        }
        
        CloudManager.setupSDK(cloudSetting: self.selectedItem) { success in
            
            DispatchQueue.main.async {
                MGLoading.stop()
                if !success {
                    MGLoading.showMessage(type: .failed, message: cloudLocalizedString("保存失败，请重试"))
                    return
                }
                
                MGLoading.showMessage(type: .success, message: cloudLocalizedString("保存成功"))
                CloudSettingManager.shared.saveCurrentSetting(item: self.selectedItem)
                self.completion?(true, true)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //检查token的有效性
    func checkToken() {
        
    }
    
    //
    func checkBtnStatus() {
        
        saveBtn.isEnabled = false
        saveBtn.backgroundColor = .lightGray
        loginBtn.isEnabled = true
        loginBtn.backgroundColor = .black
        if selectedItem.token.isEmpty {
            return
        }
        loginBtn.isEnabled = false
        loginBtn.backgroundColor = .lightGray
        if !selectedItem.rootDic.isEmpty {
            saveBtn.isEnabled = true
            saveBtn.backgroundColor = .black
        }
    }
}

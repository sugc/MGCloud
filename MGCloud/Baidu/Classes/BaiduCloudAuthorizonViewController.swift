//
//  BaiduCloudAuthorizonViewController.swift
//  MGCloud
//
//  Created by sugc on 2023/11/29.
//

import Foundation
import WebKit
import MGUIKit

public class BaiduCloudAuthorizonViewController : MGNavigaionViewController, WKNavigationDelegate {
    
    var webView : WKWebView!
    let addr = "https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=GEBsGO9FNaL78aiZU8H1up9qYHz0CGsq&redirect_uri=oob&scope=basic,netdisk&display=mobile&qrcode=1"
    
    var completion : ((_ accessToken:String?)->Void)!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView.init(frame: CGRect(x: 0,
                                               y: self.navigationView.bottom,
                                               width: UIScreen.main.bounds.width,
                                               height: UIScreen.main.bounds.height - self.navigationView.bottom))
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        //构造一下请求
        guard let req = try? URLRequest(url: URL.init(string: addr)!, method: .get) else {
            return
        }
        webView.load(req)
        
    }
    
    //
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        //跳转， 判断是否是授权之后的， 获取结果
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if url.absoluteString.hasPrefix("https://openapi.baidu.com/") {
            processRes(url: navigationAction.request.url!)
        }
        
        decisionHandler(.allow)
    }
    
    //从url中获取token
    //https://openapi.baidu.com/oauth/2.0/login_success#expires_in=2592000&access_token=123.945b5b7dbe546e256bfaee963bfa3185.YnpGmq-28zG6Bcp7VFiPUkJigJUM6mZhxwg8hXe.nboOwQ&session_secret=&session_key=&scope=basic+netdisk
    func processRes(url:URL)->Void {
        let params = getQueryStringParameters(url: url)
        guard let accessToken =  params["access_token"] else {
            return
        }
        
        //获取到token并返回
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: DispatchWorkItem(block: {
            super.goBack()
            self.completion(accessToken)
        }))
    }
    
    public override func goBack() {
        if self.webView.canGoBack {
            self.webView.goBack()
            return
        }
        super.goBack()
    }
    
    func getQueryStringParameters(url: URL) -> [String: String] {
        var parametersDic : [String: String] = [:]
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return parametersDic
        }
        
        if let queryItems = components.queryItems  {
            for item in queryItems {
                if let value = item.value {
                    parametersDic[item.name] = value
                }
            }
            return parametersDic
        }
        
        guard let fragment = components.fragment else {
            return parametersDic
        }
        
        let parmStrList = fragment.components(separatedBy: "&")
        for parmStr in parmStrList {
            let items = parmStr.components(separatedBy: "=")
            if items.count == 2 {
                parametersDic[items[0]] = items[1]
            }
        }
        
        return parametersDic
    }
    
}

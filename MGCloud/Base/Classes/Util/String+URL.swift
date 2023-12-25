//
//  String+URL.swift
//  MGCloud
//
//  Created by sugc on 2023/12/9.
//

import Foundation

public extension String {
    
    //字符串直接去除路径
    public func deletingLastPathComponent()->String! {
        var res = ""
        let resArr = self.components(separatedBy: "/")
        for i in 0..<resArr.count {
            res = res + resArr[i] + "/"
        }
        res.removeLast()
        return res
    }
    
}

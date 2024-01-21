//
//  CloudSettingItem.swift
//  Pods
//
//  Created by sugc on 2023/10/19.
//

import Foundation

public struct CloudSettingItem : Codable {
    
    var type : CloudType = .unknown
    var rootDic : String = ""
    var token : String = ""
    
    public func isValid()->Bool {
        return type != .unknown && !rootDic.isEmpty && !token.isEmpty
    }
    func cloudName()->String {
        var name = ""
        switch type {
        case .unknown:
            break
        case .apple:
            name = "Apple"
            break
        case .badidu:
            name = "Baidu"
            break
        case .google:
            name = "Google"
            break
        }
        return name
    }
    
    func toData()->Data? {
        let data = try? JSONEncoder().encode(self)
        return data
    }
    
   
    static func instanceFrom(data:Data)->CloudSettingItem? {
        let item = try? JSONDecoder().decode(CloudSettingItem.self, from: data)
        return item
    }
}

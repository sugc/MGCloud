//
//  ResourceUtil.swift
//  MGCloud
//
//  Created by sugc on 2023/12/24.
//

import Foundation
import CommonUtil 

public func cloudBundleImage(_ named:String)-> UIImage? {
    return UIImage.init(name: named, bundleName: "MGCloudResources")
}


public func cloudLocalizedString(_ key:String!)->String {
    
    return LocalizedString(key, bundleName: "MGCloudResources")
}

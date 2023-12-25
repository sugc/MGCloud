//
//  URL+CloudExtension.swift
//  MGCloud
//
//  Created by sugc on 2023/10/13.
//

import Foundation


extension URL {
    
    func cloundType()->CloudType {
        
        let str = self.absoluteString
        
        if str.hasPrefix("iCloud") {
            return .apple
        }
        
        if str.hasPrefix("Baidu") {
            return .badidu
        }
        
        return .unknown
    }
}

//
//  FileManager+Util.swift
//  MGCloud
//
//  Created by sugc on 2023/10/21.
//

import Foundation

extension  FileManager {
    
    func deleteDictionaryRecursiveAtPath(path:String)->Bool {
        
        var flag : ObjCBool = false
        
        if !self.fileExists(atPath: path, isDirectory: &flag) {
            
            return false
        }
        
        if flag.boolValue {
            var subPaths : Array<String> = []
            do {
                subPaths = try self.contentsOfDirectory(atPath: path)
            }catch {
                
                print(error)
                return false
            }
            
        
            
            for subPath in subPaths {
                let finalPath = path + "/" + subPath
                if deleteDictionaryRecursiveAtPath(path: finalPath) == false {
                    
                    print("xxxxxxxxxxxxx")
                    return false
                }
            }
            
            do {
                try removeItem(atPath: path)
            }catch {
                
                return false
            }
            
        }else {
            do {
                try removeItem(atPath: path)
            }catch {
                
                return false
            }
            
            return true
        }
        
        return true
    }
    
    func getValidTempPathNewFile()->String {
        
    
        
       return ""
    }
}

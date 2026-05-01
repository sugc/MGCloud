//
//  CloundDocument.swift
//  CommonUtil
//
//  Created by sugc on 2023/7/14.
//

import Foundation


public enum CloudType : Int, Codable {
    case unknown = 0
    case apple = 1
    case badidu = 2
    case google = 3
}

public class CloudDocument : UIDocument {
    
    public var data : Data?
    
    var cloudType : CloudType {
        get {
            
            return fileURL.cloundType()
        }
    }
    
   
    //此处进行数据转换
    public override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        data = contents as! Data
    }
    
    
    public override func contents(forType typeName: String) throws -> Any {
        
        return data ?? Data()
    }
    
}

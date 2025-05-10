//
//  FileInfoRecord.swift
//  FileInfoTool
//
//  Created on 2025/01/30.
//

import Foundation
import System

internal protocol FileInfoRecord {
    
    var name: String { get set }
    
    var directory: DirectoryInfoRecord? { get set }
    
    var creationDateUtc: String? { get set }
    
    var creationDateUtcInterval: Double? { get set }
    
    var modificationDateUtc: String? { get set }
    
    var modificationDateUtcInterval: Double? { get set }
    
    var accessDateUtc: String? { get set }
    
    var accessDateUtcInterval: Double? { get set }
}

internal extension FileInfoRecord {
    
    var relativePath: String {
        var pathNames = [String]()
        
        pathNames.append(name)
        
        var parent: DirectoryInfoRecord? = directory
        while (parent != nil) {
            if let parentName = parent?.name {
                pathNames.append(parentName)
            }
            parent = parent?.directory
        }
        
        pathNames.removeLast()
        pathNames.reverse()
        
        var path = FilePath("")
        for pathName in pathNames {
            path.append(FilePath.Component(stringLiteral: pathName))
        }
        return path.string
    }
    
    static func compareByName(lInfo: any FileInfoRecord, rInfo: any FileInfoRecord) -> Bool {
        return lInfo.name < rInfo.name
    }
}

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
    
    var creationTimeUtc: String? { get set }
    
    var creationTimeUtcInterval: Double? { get set }
    
    var lastWriteTimeUtc: String? { get set }
    
    var lastWriteTimeUtcInterval: Double? { get set }
    
    var lastAccessTimeUtc: String? { get set }
    
    var lastAccessTimeUtcInterval: Double? { get set }
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
}

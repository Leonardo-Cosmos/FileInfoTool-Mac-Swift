//
//  InfoAttribute.swift
//  FileInfoTool
//
//  Created on 2024/11/27.
//

import Foundation

/// The value indicating an attribute of file or directory.
enum InfoAttribute: CaseIterable {
    /// Date created
    case CreationTime
    
    /// Date modified
    case LastWriteTime
    
    /// Date accessed
    case LastAccessTime
    
    /// File size
    case Size
    
    /// Hash of file content
    case Hash
}

let validaSaveFileAttributes = [
    InfoAttribute.CreationTime,
    InfoAttribute.LastWriteTime,
    InfoAttribute.LastAccessTime,
    InfoAttribute.Size,
    InfoAttribute.Hash,
]

let validValidateFileAttributes = [
    InfoAttribute.CreationTime,
    InfoAttribute.LastWriteTime,
    InfoAttribute.LastAccessTime,
    InfoAttribute.Size,
    InfoAttribute.Hash,
]

let validRestoreFileAttributes = [
    InfoAttribute.CreationTime,
    InfoAttribute.LastWriteTime,
    InfoAttribute.LastAccessTime,
]

let validDirProperties = [
    InfoAttribute.CreationTime,
    InfoAttribute.LastWriteTime,
    InfoAttribute.LastAccessTime,
]

internal extension InfoAttribute {
    func nameString() -> String {
        switch self {
        case .CreationTime:
            return "Date created"
        case .LastWriteTime:
            return "Date modified"
        case .LastAccessTime:
            return "Date accessed"
        case .Size:
            return "Size"
        case .Hash:
            return "Hash"
        }
    }
}

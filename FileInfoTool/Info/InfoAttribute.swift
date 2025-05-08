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
    case CreationDate
    
    /// Date modified
    case ModificationDate
    
    /// Date accessed
    case AccessDate
    
    /// File size
    case Size
    
    /// Hash of file content
    case Hash
}

let validFileAttributes = [
    InfoAttribute.CreationDate,
    InfoAttribute.ModificationDate,
    InfoAttribute.AccessDate,
    InfoAttribute.Size,
    InfoAttribute.Hash,
]

let validRestoreFileAttributes = [
    InfoAttribute.CreationDate,
    InfoAttribute.ModificationDate,
    InfoAttribute.AccessDate,
]

let validDirProperties = [
    InfoAttribute.CreationDate,
    InfoAttribute.ModificationDate,
    InfoAttribute.AccessDate,
]

internal extension InfoAttribute {
    var nameString: String {
        switch self {
        case .CreationDate:
            return "Date created"
        case .ModificationDate:
            return "Date modified"
        case .AccessDate:
            return "Date accessed"
        case .Size:
            return "Size"
        case .Hash:
            return "Hash"
        }
    }
}

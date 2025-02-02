//
//  Errors.swift
//  FileInfoTool
//
//  Created on 2025/01/31.
//

import Foundation

enum ArgumentError: Error {
    case missingMode
    case unknownMode(String)
    case onRootDir
    case unknownAttribute(String)
    case unknownArguments(String)
}

enum RuntimeError: Error {
    case targetDirNotExists(String)
    case infoFileExists(String)
}

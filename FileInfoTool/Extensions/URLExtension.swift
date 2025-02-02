//
//  URLExtension.swift
//  FileInfoTool
//
//  Created on 2025/02/01.
//

import Foundation
import System

extension URL {
    
    init(filePathString: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: filePathString)
        } else {
            self.init(fileURLWithPath: filePathString)
        }
    }
    
    init(fileNotDirPath: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: fileNotDirPath, directoryHint: .notDirectory)
        } else {
            self.init(fileURLWithPath: fileNotDirPath, isDirectory: false)
        }
    }
    
    init(dirPath: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: dirPath, directoryHint: .isDirectory)
        } else {
            self.init(fileURLWithPath: dirPath, isDirectory: true)
        }
    }
    
    func appending(fileNotDirPath: String) -> URL {
        if #available(macOS 13.0, *) {
            self.appending(path: fileNotDirPath, directoryHint: .notDirectory)
        } else {
            self.appendingPathComponent(fileNotDirPath, isDirectory: false)
        }
    }
    
    func appending(dirPath: String) -> URL {
        if #available(macOS 13.0, *) {
            self.appending(path: dirPath, directoryHint: .isDirectory)
        } else {
            self.appendingPathComponent(dirPath, isDirectory: true)
        }
    }
    
    func relativePath(baseUrl: URL) -> String {
        return self.standardPath.replacingOccurrences(of: baseUrl.purePath, with: "")
    }
    
    var purePath: String {
        if #available(macOS 13.0, *) {
            return FilePath(self.path(percentEncoded: false)).string
        } else {
            return self.path
        }
    }
    
    var standardPath: String {
        if #available(macOS 13.0, *) {
            return self.path(percentEncoded: false)
        } else {
            if self.hasDirectoryPath {
                return "\(self.path)/"
            } else {
                return self.path
            }
        }
    }
}

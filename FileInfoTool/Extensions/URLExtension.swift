//
//  URLExtension.swift
//  FileInfoTool
//
//  Created on 2025/02/01.
//

import Foundation
import System

extension URL {
    
    private static func standardizePath(_ path: String) -> String {
        return path.replacingOccurrences(pattern: "(?<=/)\\./", with: "")
            .replacingOccurrences(pattern: "(?<=/)[^/]+/\\.\\./", with: "")
    }
    
    init(filePathString: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: Self.standardizePath(filePathString))
        } else {
            self.init(fileURLWithPath: Self.standardizePath(filePathString))
        }
    }
    
    init(fileNotDirPath: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: Self.standardizePath(fileNotDirPath), directoryHint: .notDirectory)
        } else {
            self.init(fileURLWithPath: Self.standardizePath(fileNotDirPath), isDirectory: false)
        }
    }
    
    init(dirPath: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: Self.standardizePath(dirPath), directoryHint: .isDirectory)
        } else {
            self.init(fileURLWithPath: Self.standardizePath(dirPath), isDirectory: true)
        }
    }
    
    func appending(fileNotDirPath: String) -> URL {
        if #available(macOS 13.0, *) {
            self.appending(path: Self.standardizePath(fileNotDirPath), directoryHint: .notDirectory)
        } else {
            self.appendingPathComponent(Self.standardizePath(fileNotDirPath), isDirectory: false)
        }
    }
    
    func appending(dirPath: String) -> URL {
        if #available(macOS 13.0, *) {
            self.appending(path: Self.standardizePath(dirPath), directoryHint: .isDirectory)
        } else {
            self.appendingPathComponent(Self.standardizePath(dirPath), isDirectory: true)
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

//
//  ConsoleArgsParser.swift
//  FileInfoTool
//
//  Created on 2024/11/27.
//

import Foundation
import System

enum Mode: String, CaseIterable {
    /// Save file sytem info to a record.
    case Save = "save"

    /// List info of saved record.
    case List = "list"

    /// Validate if file system info is changed from saved value.
    case Validate = "validate"
    
    /// Restore file system info to saved value if it is changed.
    /// Not all info attributes are supported.
    case Restore = "restore"
    
    /// Extract a sub directory to another record.
    case ExtractSub = "extractSub"
    
    /// Add another record as a sub directory.
    case AddSub = "addSub"
    
    /// Remove a sub directory.
    case RemoveSub = "removeSub"
}

extension Mode {
    var requiresInputFile: Bool {
        return self == .Restore || self == .Validate || self == .List
    }
    
    var requiresOutputFile: Bool {
        return self == .Save
    }
}

struct LaunchOption {
    let mode: Mode
    let dirPath: String
    let inputFile: String?
    let outputFile: String?
    let fileAttributeNames: [InfoAttribute]?
    let dirAttributeNames: [InfoAttribute]?
    let recursive: Bool
    let baseFile: String?
    let relativePath: String?
    let subFile: String?
    let overwrite: Bool
}

enum ArgumentError: Error {
    case missingMode
    case unknownMode(String)
    case onRootDir
    case unknownAttribute(String)
    case unknownArguments(String)
}

internal class ConsoleArgsParser {
    private static let dirPathKeys: [String] = ["-d", "-dir" ]
    
    private static let inputFilePathKeys: [String] = [ "-i", "-input" ]
    
    private static let outputFilePathKeys: [String] = [ "-o", "-output" ]
    
    private static let recursiveKeys: [String] = [ "-r", "-recursive" ]
    
    private static let attributeKeys: [String] = [ "-attr", "-attribute" ]
    
    private static let fileAttributeKeys: [String] = [ "-fattr", "-file-attr", "-file-attribute" ]
    
    private static let dirAttributeKeys: [String] = [ "-dattr", "-dir-attr", "-dir-attribute" ]
    
    private static let baseFilePathKeys: [String] = [ "-base", "-base-info" ]
    
    private static let relativePathKeys: [String] = [ "-path", "-relative-path" ]
    
    private static let subFilePathKeys: [String] = [ "-sub", "-sub-info" ]
    
    private static let overwriteKeys: [String] = [ "-ow", "-over-write" ]
    
    private static let creationTimeAttributeValue: String = "c";
    
    private static let lastWriteTimeAttributeValue: String = "m";
    
    private static let lastAccessAttributeValue: String = "a";
    
    private static let sizeAttributeValue: String = "s";
    
    private static let hashAttributeValue: String = "h";
    
    private static let wildcardAttributeValue: String = "*";
    
    static func parseArgs(args: [String]) throws -> LaunchOption {
        guard args.count > 0 && !args[0].starts(with: "-") else {
            throw ArgumentError.missingMode
        }
        
        let modeArg = args[0]
        var mode: Mode? = nil
        for modeValue in Mode.allCases {
            if modeValue.rawValue.caseInsensitiveCompare(modeArg) == .orderedSame {
                mode = modeValue
                break
            }
        }
        
        guard let mode = mode else {
            throw ArgumentError.unknownMode(modeArg)
        }
        
        // Convert arguments to key value pairs, skipping the mode argument.
        var argDict = convertArgsToDict(args: Array(args.dropFirst(1)))
        
        let dirPath: String? = takeArgValue(argDict: &argDict, argKeys: dirPathKeys)
        // Make sure the directory path is absolute.
        // Use working directory by default.
        let dirUrl = fileURL(dirPath: (dirPath ?? "."))
        
        if dirUrl.absoluteString == "/" {
            throw ArgumentError.onRootDir
        }
        
        func defaultInfoFilePath() -> URL {
            let defaultFileName = String(format: InfoRecord.defaultFileNameFormat, dirUrl.lastPathComponent)
            return URL(fileURLWithPath: defaultFileName, isDirectory: true, relativeTo: dirUrl.deletingLastPathComponent())
        }
        
        var inputFilePath = takeArgValue(argDict: &argDict, argKeys: inputFilePathKeys)
        if mode.requiresInputFile && inputFilePath == nil {
            inputFilePath = defaultInfoFilePath().absoluteString
        }
        
        var outputFilePath = takeArgValue(argDict: &argDict, argKeys: outputFilePathKeys)
        if mode.requiresOutputFile && outputFilePath == nil {
            outputFilePath = defaultInfoFilePath().absoluteString
        }
        
        var recursive = takeArgValue(argDict: &argDict, argKeys: recursiveKeys) != nil
        
        let attributeValue = takeArgValue(argDict: &argDict, argKeys: attributeKeys)
        var fileAttributeValue = takeArgValue(argDict: &argDict, argKeys: fileAttributeKeys)
        var dirAttributeValue = takeArgValue(argDict: &argDict, argKeys: dirAttributeKeys)
        if let attributeValue = attributeValue {
            fileAttributeValue = fileAttributeValue ?? attributeValue
            dirAttributeValue = dirAttributeValue ?? attributeValue
        }
        
        var fileAttributes: [InfoAttribute]?
        if let fileAttributeValue = fileAttributeValue {
            fileAttributes = try parseAttributeValue(attributeValue: fileAttributeValue)
        } else {
            fileAttributes = nil
        }
        
        var dirAttributes: [InfoAttribute]?
        if let dirAttributeValue = dirAttributeValue {
            dirAttributes = try parseAttributeValue(attributeValue: dirAttributeValue)
        } else {
            dirAttributes = nil
        }
        
        let baseFilePath = takeArgValue(argDict: &argDict, argKeys: baseFilePathKeys)
        
        let relativePath = takeArgValue(argDict: &argDict, argKeys: relativePathKeys)
        
        let subFilePath = takeArgValue(argDict: &argDict, argKeys: subFilePathKeys)
        
        let overwrite = takeArgValue(argDict: &argDict, argKeys: overwriteKeys) != nil
        
        if argDict.count > 0 {
            let unknownArgs = convertDictToArgs(argDict: argDict)
            throw ArgumentError.unknownArguments(unknownArgs.joined(separator: " "))
        }
        
        return LaunchOption(mode: mode,
                            dirPath: dirUrl.absoluteString,
                            inputFile: inputFilePath,
                            outputFile: outputFilePath,
                            fileAttributeNames: fileAttributes,
                            dirAttributeNames: dirAttributes,
                            recursive: recursive,
                            baseFile: baseFilePath,
                            relativePath: relativePath,
                            subFile: subFilePath,
                            overwrite: overwrite
        )
    }
    
    private static func convertArgsToDict(args: [String]) -> [String: String] {
        return args.reduce(into: [String: String]()) { dict, arg in
            guard arg.starts(with: "-") else {
                return
            }
            let values = arg.split(separator: "=").map { String($0) }
            if values.count > 1 {
                // Argument of key value pair.
                dict[values[0]] = values[1]
            } else {
                // Argument of key only.
                dict[values[0]] = ""
            }
        }
    }
    
    private static func convertDictToArgs(argDict: [String: String]) -> [String] {
        return argDict.reduce(into: [String]()) { args, element in
            if element.value.isEmpty {
                args.append(element.key)
            } else {
                args.append("\(element.key)=\(element.value)")
            }
        }
    }
    
    private static func takeArgValue(argDict: inout [String: String], argKeys: [String]) -> String? {
        let firstFoundKey = argKeys.first(where: argDict.keys.contains(_:))
        guard let argKey = firstFoundKey else {
            return nil
        }
        let argValue = argDict[argKey]
        argDict.removeValue(forKey: argKey)
        return argValue
    }
    
    private static func fileURL(dirPath: String) -> URL {
        if dirPath.starts(with: "/") {
            return URL(fileURLWithPath: dirPath, isDirectory: true)
        } else {
            let currentDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            return URL(fileURLWithPath: dirPath, isDirectory: true, relativeTo: currentDirUrl)
        }
    }
    
    private static func parseAttributeValue(attributeValue: String) throws -> [InfoAttribute] {
        if attributeValue.contains(wildcardAttributeValue) {
            return InfoAttribute.allCases
        }
        
        var attributeNames = [InfoAttribute]()
        for attributeChar in attributeValue {
            let nameValue = attributeChar.lowercased()
            switch nameValue {
            case creationTimeAttributeValue:
                attributeNames.append(.CreationTime)
            case lastWriteTimeAttributeValue:
                attributeNames.append(.LastWriteTime)
            case lastAccessAttributeValue:
                attributeNames.append(.LastAccessTime)
            case sizeAttributeValue:
                attributeNames.append(.Size)
            case hashAttributeValue:
                attributeNames.append(.Hash)
            default:
                throw ArgumentError.unknownAttribute(nameValue)
            }
        }
        return attributeNames
    }
}

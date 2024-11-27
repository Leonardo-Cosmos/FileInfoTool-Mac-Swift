//
//  ConsoleArgsParser.swift
//  FileInfoTool
//
//  Created on 2024/11/27.
//

import Foundation

enum Mode: String, CaseIterable {
    /// Save file sytem info to a record.
    case Save = "save"

    /// List info of saved record.
    case List = "list"

    /// Validate if file system info is changed from saved value.
    case Validate = "validate"
    
    /// Restore file system info to saved value if it is changed.
    /// Not all info properties are supported.
    case Restore = "restore"
    
    /// Extract a sub directory to another record.
    case ExtractSub = "extractSub"
    
    /// Add another record as a sub directory.
    case AddSub = "addSub"
    
    /// Remove a sub directory.
    case RemoveSub = "removeSub"
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
    let fastHash: Bool
}

enum ArgumentError: Error {
    case missingMode
    case unknownMode(String)
}

internal class ConsoleArgsParser {
    private let dirPathKeys: [String] = ["-d", "-dir" ]
    
    private let inputFilePathKeys: [String] = [ "-i", "-input" ]
    
    private let outputFilePathKeys: [String] = [ "-o", "-output" ]
    
    private let recursiveKeys: [String] = [ "-r", "-recursive" ]
    
    private let propertyKeys: [String] = [ "-prop", "-property" ]
    
    private let filePropertyKeys: [String] = [ "-fprop", "-file-prop", "-file-property" ]
    
    private let dirPropertyKeys: [String] = [ "-dprop", "-dir-prop", "-dir-property" ]
    
    private let baseFilePathKeys: [String] = [ "-base", "-base-info" ]
    
    private let relativePathKeys: [String] = [ "-path", "-relative-path" ]
    
    private let subFilePathKeys: [String] = [ "-sub", "-sub-info" ]
    
    private let overwriteKeys: [String] = [ "-ow", "-over-write" ]
    
    private let creationTimePropertyValue: String = "c";
    
    private let lastWriteTimePropertyValue: String = "m";
    
    private let lastAccessPropertyValue: String = "a";
    
    private let sizePropertyValue: String = "s";
    
    private let hashPropertyValue: String = "h";
    
    private let wildcardPropertyValue: String = "*";
    
    static func parseArgs(args: [String]) throws -> LaunchOption {
        guard args.count > 0 && !args[0].starts(with: "-") else {
            throw ArgumentError.missingMode
        }
        var modeArg = args[0]
        
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
        
        return LaunchOption(mode: mode, dirPath: "", inputFile: nil, outputFile: nil, fileAttributeNames: nil, dirAttributeNames: nil, recursive: false, baseFile: "", relativePath: nil, subFile: nil, overwrite: false, fastHash: false)
    }
}

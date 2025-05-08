//
//  InfoLauncher.swift
//  FileInfoTool
//
//  Created on 2025/01/31.
//

import Foundation

internal class InfoLauncher {
    
    static func launch(option: LaunchOption) throws {
        switch (option.mode) {
        case .Save:
            try save(option: option)
        case .Restore, .Validate, .List:
            try load(option: option)
        case .ExtractSub:
            extractSubDirectory(option: option)
        case .AddSub:
            addSubDirectory(option: option)
        case .RemoveSub:
            removeSubDirectory(option: option)
        }
    }
    
    private static func save(option: LaunchOption) throws {
        try InfoSaver(dirPath: option.dirPath,
                  infoFilePath: option.outputFile!,
                  fileAttributes: option.fileAttributes,
                  dirAttributes: option.dirAttributes)
        .save(recursive: option.recursive, overwrite: option.overwrite)
    }
    
    private static func load(option: LaunchOption) throws {
        try InfoLoader(dirPath: option.dirPath,
                       infoFilePath: option.inputFile!,
                       mode: option.mode,
                       fileAttributes: option.fileAttributes,
                       dirAttributes: option.dirAttributes)
        .load(recursive: option.recursive)
    }
    
    private static func extractSubDirectory(option: LaunchOption) {
        
    }
    
    private static func addSubDirectory(option: LaunchOption) {
        
    }
    
    private static func removeSubDirectory(option: LaunchOption) {
        
    }
}

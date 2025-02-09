//
//  main.swift
//  FileInfoTool
//
//  Created on 2024/6/11.
//

import Foundation

var launchOption: LaunchOption? = nil
do {
    let args = Array(CommandLine.arguments.dropFirst(1))
    launchOption = try ConsoleArgsParser.parseArgs(args: args)
} catch ArgumentError.missingMode {
    print("Mode is not specified")
} catch ArgumentError.unknownMode(let mode) {
    print("Unknown mode: \(mode)")
} catch ArgumentError.onRootDir {
    print("Cannot execute against a root path")
}

if let launchOption = launchOption {
    do {
        try InfoLauncher.launch(option: launchOption)
    } catch RuntimeError.targetDirNotExists(let dirPath) {
        print("Directory doesn't exist, path: \(dirPath)")
    } catch RuntimeError.infoFileExists(let infoFilePath) {
        print("Info file exists already, path: \(infoFilePath)")
    } catch RuntimeError.infoFileNotExists(let infoFilePath) {
        print("Info file doesn't exist, path: \(infoFilePath)")
    } catch RuntimeError.invalidInfoFile(let infoFilePath) {
        print("Invalid info file, path: \(infoFilePath)")
    }
}

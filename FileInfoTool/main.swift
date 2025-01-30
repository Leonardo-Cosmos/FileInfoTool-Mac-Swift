//
//  main.swift
//  FileInfoTool
//
//  Created on 2024/6/11.
//

import Foundation

do {
    let launchOption = try ConsoleArgsParser.parseArgs(args: CommandLine.arguments)
} catch ArgumentError.missingMode {
    print("Mode is not specified")
} catch ArgumentError.unknownMode(let mode) {
    print("Unknown mode: \(mode)")
} catch ArgumentError.onRootDir {
    print("Cannot execute against a root path")
}


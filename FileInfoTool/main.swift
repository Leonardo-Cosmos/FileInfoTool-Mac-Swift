//
//  main.swift
//  FileInfoTool
//
//  Created on 2024/6/11.
//

import Foundation

do {
    let launchOption = try ConsoleArgsParser.parseArgs(args: CommandLine.arguments)
} catch ArgumentError.unknownMode(let mode) {
    print("Unknown mode: \(mode)")
}


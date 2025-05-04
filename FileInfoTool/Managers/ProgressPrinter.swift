//
//  ProgressPrinter.swift
//  FileInfoTool
//
//  Created on 2025/05/02.
//

import Foundation

internal class ProgressPrinter {
    
    private let format: String
    
    private var started = false
    
    private var ended = false
    
    private var lastProgressLength = 0
    
    init(format: String) {
        self.format = format
    }
    
    private static func moveToHead() {
        print("\r", terminator: "")
    }
    
    private static func printText(_ value: String) {
        print(value, terminator: "")
        
        // Ensure immediate output
        fflush(stdout)
    }
    
    private static func eraseLine() {
        moveToHead()
        let terminalWidth = getTerminalWidth()
        let eraseText = String(repeating: " ", count: terminalWidth)
        printText(eraseText)
    }
    
    private static func getTerminalWidth() -> Int {
//        var winsize = winsize()
//        let value = ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsize)
//        return Int(winsize.ws_col)
        return 100
    }
    
    private func formatProgress(_ progressValues: CVarArg...) -> String {
        let progress = String(format: format, progressValues)
        let terminalWidth = Self.getTerminalWidth()
        if progress.count > terminalWidth {
            let index = progress.index(progress.startIndex, offsetBy: terminalWidth)
            return String(progress[...index])
        }
        return progress
    }
    
    func start(_ progressValues: CVarArg...) {
        started = true
        
        let progressText = formatProgress(progressValues)
        Self.printText(progressText)
        
        lastProgressLength = progressText.count
    }
    
    func update(_ progressValues: CVarArg...) {
        if ended {
            return
        }
        
        if started {
            let progressText = formatProgress(progressValues)
            if progressText.count < lastProgressLength {
                Self.eraseLine()
            }
            
            Self.moveToHead()
            Self.printText(progressText)
            
            lastProgressLength = progressText.count
        } else {
            start(progressValues)
        }
    }
    
    func end() {
        ended = true
        
        if started {
            Self.eraseLine()
            Self.moveToHead()
        }
    }
}

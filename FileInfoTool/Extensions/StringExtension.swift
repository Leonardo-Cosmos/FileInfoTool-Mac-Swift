//
//  StringExtension.swift
//  FileInfoTool
//
//  Created on 2025/05/04.
//

import Foundation

extension String {
    
    /// Returns a new string in which all matching substrings of a regular expression  are replaced by another given string.
    func replacingOccurrences(pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return self
        }
        
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.stringByReplacingMatches(in: self, range: range, withTemplate: replacement)
    }
}

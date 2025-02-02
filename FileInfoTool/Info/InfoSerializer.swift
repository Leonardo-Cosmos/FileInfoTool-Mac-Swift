//
//  InfoSerializer.swift
//  FileInfoTool
//
//  Created on 2025/01/30.
//

import Foundation

internal class InfoSerializer {
    
    static func serialize(infoRecord: InfoRecord, infoFilePath: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try encoder.encode(infoRecord)
        try json.write(to: URL(fileURLWithPath: infoFilePath))
        
        print()
        print("Write to info file: \(infoFilePath)")
        print()
    }
    
    static func deserialize(infoFilePath: String) throws -> InfoRecord? {
        let decoder = JSONDecoder()
        let json = try Data(contentsOf: URL(fileURLWithPath: infoFilePath, isDirectory: false))
        print()
        print("Read from info file: \(infoFilePath)")
        print()
        
        let infoRecord = try decoder.decode(InfoRecord.self, from: json)
        return infoRecord
    }
}

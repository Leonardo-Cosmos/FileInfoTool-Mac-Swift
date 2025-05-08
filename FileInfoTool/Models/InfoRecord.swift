//
//  InfoRecord.swift
//  FileInfoTool
//
//  Created on 2025/01/29.
//

import Foundation

internal class InfoRecord: Codable {
    
    static let defaultFileNameFormat = "%@_Info.json"
    
    var recordTimeUtc: String
    
    var recordTimeUtcInterval: Double
    
    var directory: DirectoryInfoRecord
    
    private init(recordTimeUtc: String, recordTimeUtcTicks: Double, directory: DirectoryInfoRecord) {
        self.recordTimeUtc = recordTimeUtc
        self.recordTimeUtcInterval = recordTimeUtcTicks
        self.directory = directory
    }
    
    /// Create an instance with current time.
    /// - Parameters:
    ///  - directory: The `DirectoryInfoRecord` representing the target directory.
    /// - Returns: A `InfoRecord` instance of current time.
    static func create(dirInfoRecord: DirectoryInfoRecord) -> InfoRecord {
        let currentDate = Date()
        return InfoRecord(recordTimeUtc: currentDate.ISO8601Format(),
                          recordTimeUtcTicks: currentDate.timeIntervalSince1970,
                          directory: dirInfoRecord)
    }
    
    static func update(infoRecord: InfoRecord) {
        let currentDate = Date()
        infoRecord.recordTimeUtc = currentDate.ISO8601Format()
        infoRecord.recordTimeUtcInterval = currentDate.timeIntervalSince1970
    }
}

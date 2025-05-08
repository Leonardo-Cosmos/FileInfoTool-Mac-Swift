//
//  DirectoryInfoRecord.swift
//  FileInfoTool
//
//  Created on 2025/01/30.
//

import Foundation

internal class DirectoryInfoRecord: FileInfoRecord, Codable {
    
    var name: String
    
    var directory: DirectoryInfoRecord?
    
    var creationDateUtc: String?
    
    var creationDateUtcInterval: Double?
    
    var modificationDateUtc: String?
    
    var modificationDateUtcInterval: Double?
    
    var accessDateUtc: String?
    
    var accessDateUtcInterval: Double?
    
    var files: [RegularFileInfoRecord]?
    
    var directories: [DirectoryInfoRecord]?
    
    var getFilesFailed: Bool = false
    
    init(name: String, directory: DirectoryInfoRecord? = nil,
         creationDateUtc: String? = nil, creationDateUtcInterval: Double? = nil,
         modificationDateUtc: String? = nil, modificationDateUtcInterval: Double? = nil,
         accessDateUtc: String? = nil, accessDateUtcInterval: Double? = nil,
         files: [RegularFileInfoRecord]? = nil, directories: [DirectoryInfoRecord]? = nil) {
        self.name = name
        self.directory = directory
        self.creationDateUtc = creationDateUtc
        self.creationDateUtcInterval = creationDateUtcInterval
        self.modificationDateUtc = modificationDateUtc
        self.modificationDateUtcInterval = modificationDateUtcInterval
        self.accessDateUtc = accessDateUtc
        self.accessDateUtcInterval = accessDateUtcInterval
        self.files = files
        self.directories = directories
    }
    
    var relativePath: String {
        let fileInfo = self as FileInfoRecord
        return URL(fileURLWithPath: fileInfo.relativePath, isDirectory: true).relativePath
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.creationDateUtc, forKey: .creationDateUtc)
        try container.encodeIfPresent(self.creationDateUtcInterval, forKey: .creationDateUtcInterval)
        try container.encodeIfPresent(self.modificationDateUtc, forKey: .modificationDateUtc)
        try container.encodeIfPresent(self.modificationDateUtcInterval, forKey: .modificationDateUtcInterval)
        try container.encodeIfPresent(self.accessDateUtc, forKey: .accessDateUtc)
        try container.encodeIfPresent(self.accessDateUtcInterval, forKey: .accessDateUtcInterval)
        
        try container.encodeIfPresent(self.files, forKey: .files)
        try container.encodeIfPresent(self.directories, forKey: .directories)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.creationDateUtc = try container.decodeIfPresent(String.self, forKey: .creationDateUtc)
        self.creationDateUtcInterval = try container.decodeIfPresent(Double.self, forKey: .creationDateUtcInterval)
        self.modificationDateUtc = try container.decodeIfPresent(String.self, forKey: .modificationDateUtc)
        self.modificationDateUtcInterval = try container.decodeIfPresent(Double.self, forKey: .modificationDateUtcInterval)
        self.accessDateUtc = try container.decodeIfPresent(String.self, forKey: .accessDateUtc)
        self.accessDateUtcInterval = try container.decodeIfPresent(Double.self, forKey: .accessDateUtcInterval)
        
        self.files = try container.decodeIfPresent([RegularFileInfoRecord].self, forKey: .files)
        self.directories = try container.decodeIfPresent([DirectoryInfoRecord].self, forKey: .directories)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case creationDateUtc
        case creationDateUtcInterval
        case modificationDateUtc
        case modificationDateUtcInterval
        case accessDateUtc
        case accessDateUtcInterval
        case files
        case directories
    }
}

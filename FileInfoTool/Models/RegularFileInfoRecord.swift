//
//  RegularFileInfoRecord.swift
//  FileInfoTool
//
//  Created on 2025/01/30.
//

import Foundation

internal class RegularFileInfoRecord: FileInfoRecord, Codable {
    
    var name: String
    
    var directory: DirectoryInfoRecord?
    
    var creationTimeUtc: String?
    
    var creationTimeUtcInterval: Double?
    
    var lastWriteTimeUtc: String?
    
    var lastWriteTimeUtcInterval: Double?
    
    var lastAccessTimeUtc: String?
    
    var lastAccessTimeUtcInterval: Double?
    
    var size: Int?
    
    var sha512: String?
    
    var computeHashFailed: Bool = false
    
    init(name: String, directory: DirectoryInfoRecord? = nil,
         creationTimeUtc: String? = nil, creationTimeUtcInterval: Double? = nil,
         lastWriteTimeUtc: String? = nil, lastWriteTimeUtcInterval: Double? = nil,
         lastAccessTimeUtc: String? = nil, lastAccessTimeUtcInterval: Double? = nil,
         size: Int? = nil, sha512: String? = nil) {
        self.name = name
        self.directory = directory
        self.creationTimeUtc = creationTimeUtc
        self.creationTimeUtcInterval = creationTimeUtcInterval
        self.lastWriteTimeUtc = lastWriteTimeUtc
        self.lastWriteTimeUtcInterval = lastWriteTimeUtcInterval
        self.lastAccessTimeUtc = lastAccessTimeUtc
        self.lastAccessTimeUtcInterval = lastAccessTimeUtcInterval
        self.size = size
        self.sha512 = sha512
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.creationTimeUtc, forKey: .creationTimeUtc)
        try container.encodeIfPresent(self.creationTimeUtcInterval, forKey: .creationTimeUtcInterval)
        try container.encodeIfPresent(self.lastWriteTimeUtc, forKey: .lastWriteTimeUtc)
        try container.encodeIfPresent(self.lastWriteTimeUtcInterval, forKey: .lastWriteTimeUtcInterval)
        try container.encodeIfPresent(self.lastAccessTimeUtc, forKey: .lastAccessTimeUtc)
        try container.encodeIfPresent(self.lastAccessTimeUtcInterval, forKey: .lastAccessTimeUtcInterval)
        
        try container.encodeIfPresent(self.size, forKey: .size)
        try container.encodeIfPresent(self.sha512, forKey: .sha512)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.creationTimeUtc = try container.decodeIfPresent(String.self, forKey: .creationTimeUtc)
        self.creationTimeUtcInterval = try container.decodeIfPresent(Double.self, forKey: .creationTimeUtcInterval)
        self.lastWriteTimeUtc = try container.decodeIfPresent(String.self, forKey: .lastWriteTimeUtc)
        self.lastWriteTimeUtcInterval = try container.decodeIfPresent(Double.self, forKey: .lastWriteTimeUtcInterval)
        self.lastAccessTimeUtc = try container.decodeIfPresent(String.self, forKey: .lastAccessTimeUtc)
        self.lastAccessTimeUtcInterval = try container.decodeIfPresent(Double.self, forKey: .lastAccessTimeUtcInterval)
        
        self.size = try container.decodeIfPresent(Int.self, forKey: .size)
        self.sha512 = try container.decodeIfPresent(String.self, forKey: .sha512)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case creationTimeUtc
        case creationTimeUtcInterval
        case lastWriteTimeUtc
        case lastWriteTimeUtcInterval
        case lastAccessTimeUtc
        case lastAccessTimeUtcInterval
        case size
        case sha512
    }
}

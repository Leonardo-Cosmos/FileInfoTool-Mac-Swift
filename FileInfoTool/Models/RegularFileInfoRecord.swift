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
    
    var creationDateUtc: String?
    
    var creationDateUtcInterval: Double?
    
    var modificationDateUtc: String?
    
    var modificationDateUtcInterval: Double?
    
    var accessDateUtc: String?
    
    var accessDateUtcInterval: Double?
    
    var size: Int?
    
    var sha512: String?
    
    var computeHashFailed: Bool = false
    
    init(name: String, directory: DirectoryInfoRecord? = nil,
         creationDateUtc: String? = nil, creationDateUtcInterval: Double? = nil,
         modificationDateUtc: String? = nil, modificationDateUtcInterval: Double? = nil,
         accessDateUtc: String? = nil, accessDateUtcInterval: Double? = nil,
         size: Int? = nil, sha512: String? = nil) {
        self.name = name
        self.directory = directory
        self.creationDateUtc = creationDateUtc
        self.creationDateUtcInterval = creationDateUtcInterval
        self.modificationDateUtc = modificationDateUtc
        self.modificationDateUtcInterval = modificationDateUtcInterval
        self.accessDateUtc = accessDateUtc
        self.accessDateUtcInterval = accessDateUtcInterval
        self.size = size
        self.sha512 = sha512
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
        
        try container.encodeIfPresent(self.size, forKey: .size)
        try container.encodeIfPresent(self.sha512, forKey: .sha512)
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
        
        self.size = try container.decodeIfPresent(Int.self, forKey: .size)
        self.sha512 = try container.decodeIfPresent(String.self, forKey: .sha512)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case creationDateUtc
        case creationDateUtcInterval
        case modificationDateUtc
        case modificationDateUtcInterval
        case accessDateUtc
        case accessDateUtcInterval
        case size
        case sha512
    }
}

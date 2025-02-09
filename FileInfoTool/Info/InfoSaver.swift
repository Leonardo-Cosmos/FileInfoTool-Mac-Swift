//
//  InfoSaver.swift
//  FileInfoTool
//
//  Created on 2025/01/31.
//

import Foundation

internal class InfoSaver {
    
    private let dirPath: String
    
    private let infoFilePath: String
    
    private let fileAttributes: [InfoAttribute]
    
    private let saveFileCreationDate: Bool
    
    private let saveFileModificationDate: Bool
    
    private let saveFileLastAccessDate: Bool
    
    private let saveFileSize: Bool
    
    private let saveFileHash: Bool
    
    private let dirAttributes: [InfoAttribute]
    
    private let saveDirCreationDate: Bool
    
    private let saveDirModificationDate: Bool
    
    private let saveDirAccessDate: Bool
    
    private var savedFileCount: Int
    
    private var savedDirectoryCount: Int
    
    init(dirPath: String, infoFilePath: String,
         fileAttributes: [InfoAttribute]?, dirAttributes: [InfoAttribute]?) {
        
        self.dirPath = dirPath
        self.infoFilePath = infoFilePath
        
        if let fileAttributes = fileAttributes {
            self.fileAttributes = fileAttributes.filter { attr in
                validFileAttributes.contains(attr) }
        } else {
            self.fileAttributes = [
                .CreationDate,
                .ModificationDate,
                .AccessDate,
                .Size,
            ]
        }
        
        if let dirAttributes = dirAttributes {
            self.dirAttributes = dirAttributes.filter { attr in
                validDirProperties.contains(attr) }
        } else {
            self.dirAttributes = [
                .CreationDate,
                .ModificationDate,
                .AccessDate,
            ]
        }
        
        saveFileCreationDate = self.fileAttributes.contains(.CreationDate)
        saveFileModificationDate = self.fileAttributes.contains(.ModificationDate)
        saveFileLastAccessDate = self.fileAttributes.contains(.AccessDate)
        saveFileSize = self.fileAttributes.contains(.Size)
        saveFileHash = self.fileAttributes.contains(.Hash)
        
        saveDirCreationDate = self.dirAttributes.contains(.CreationDate)
        saveDirModificationDate = self.dirAttributes.contains(.ModificationDate)
        saveDirAccessDate = self.dirAttributes.contains(.AccessDate)
        
        savedFileCount = 0
        savedDirectoryCount = 0
    }
    
    func save(recursive: Bool, overwrite: Bool) throws {
        let fileAttributeNames = fileAttributes.map { attr in attr.nameString }
        let dirAttributeNames = dirAttributes.map { attr in attr.nameString }
        
        print("""
        Save file system info
            directory: \(dirPath)
            recursive: \(recursive)
            info file: \(infoFilePath)
            overwrite: \(overwrite)
            file attributes: \(fileAttributeNames.joined(separator: ", "))
            directory attributes: \(dirAttributeNames.joined(separator: ", "))
        
        """)
        
        guard FileManager.default.fileExists(atPath: dirPath) else {
            throw RuntimeError.targetDirNotExists(dirPath)
        }
        
        guard !FileManager.default.fileExists(atPath: infoFilePath) || overwrite else {
            throw RuntimeError.infoFileExists(infoFilePath)
        }
        
        savedFileCount = 0
        savedDirectoryCount = 0
        let dirUrl = URL(dirPath: dirPath)
        let dirInfoRecord = try save(dirUrl: dirUrl, recursive: recursive)
        print("""
        Saved
            file: \(savedFileCount)
            directory: \(savedDirectoryCount)
        """)
        
        let infoRecord = InfoRecord.create(dirInfoRecord: dirInfoRecord)
        
        try InfoSerializer.serialize(infoRecord: infoRecord, infoFilePath: infoFilePath)
    }
    
    private func save(dirUrl: URL, recursive: Bool) throws -> DirectoryInfoRecord {
        
        let dirInfoRecord = try saveInfoRecord(url:dirUrl) as! DirectoryInfoRecord
        
        var fileUrls: [URL]
        do {
            fileUrls = try FileManager.default.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            dirInfoRecord.getFilesFailed = true;
            fileUrls = []
        }
        
        let regularFileUrls = fileUrls.filter { url in !url.hasDirectoryPath }
        var regularFileInfoRecords: [RegularFileInfoRecord] = []
        for regularFileUrl in regularFileUrls {
            let regularFileInfoRecord = try saveInfoRecord(url: regularFileUrl) as! RegularFileInfoRecord
            regularFileInfoRecords.append(regularFileInfoRecord)
        }
        regularFileInfoRecords.sort(by: RegularFileInfoRecord.compareByName(lInfo:rInfo:))
        dirInfoRecord.files = regularFileInfoRecords
        
        if recursive {
            let subDirUrls = fileUrls.filter { url in url.hasDirectoryPath }
            var subDirInfoRecords: [DirectoryInfoRecord] = []
            for subDirUrl in subDirUrls {
                let subDirInfoRecord = try save(dirUrl: subDirUrl, recursive: recursive)
                subDirInfoRecords.append(subDirInfoRecord)
            }
            subDirInfoRecords.sort(by: DirectoryInfoRecord.compareByName(lInfo:rInfo:))
            dirInfoRecord.directories = subDirInfoRecords
        }
        
        return dirInfoRecord
    }
    
    private func saveInfoRecord(url: URL) throws -> FileInfoRecord {
        
        var saveCreationDate = false;
        var saveModificationDate = false;
        var saveAccessDate = false;
        var saveSize = false;
        var saveHash = false;
        if url.hasDirectoryPath {
            savedDirectoryCount += 1
            
            saveCreationDate = saveDirCreationDate
            saveModificationDate = saveDirModificationDate
            saveAccessDate = saveDirAccessDate
            
        } else {
            savedFileCount += 1
            
            saveCreationDate = saveFileCreationDate
            saveModificationDate = saveFileModificationDate
            saveAccessDate = saveFileLastAccessDate
            saveSize = saveFileSize
            saveHash = saveFileHash
        }
        
        var infoRecord: FileInfoRecord
        if url.hasDirectoryPath {
            infoRecord = DirectoryInfoRecord(name: url.lastPathComponent)
        } else {
            infoRecord = RegularFileInfoRecord(name: url.lastPathComponent)
        }
        
        var resourceKeys: Set<URLResourceKey> = []
        if saveCreationDate {
            resourceKeys.insert(.creationDateKey)
        }
        if saveModificationDate {
            resourceKeys.insert(.contentModificationDateKey)
        }
        if saveAccessDate {
            resourceKeys.insert(.contentAccessDateKey)
        }
        if saveSize {
            resourceKeys.insert(.fileSizeKey)
        }
        
        let resourceValues = try url.resourceValues(forKeys: resourceKeys)
        
        if saveCreationDate {
            infoRecord.creationDateUtc = resourceValues.creationDate?.ISO8601Format()
        }
        if saveModificationDate {
            infoRecord.modificationDateUtc = resourceValues.contentModificationDate?.ISO8601Format()
        }
        if saveAccessDate {
            infoRecord.accessDateUtc = resourceValues.contentAccessDate?.ISO8601Format()
        }
        if saveSize {
            let fileInfoRecord = infoRecord as! RegularFileInfoRecord
            fileInfoRecord.size = resourceValues.fileSize
        }
        
        printSavedInfoRecord(url: url, infoRecord: infoRecord)
        return infoRecord
    }
    
    private func printSavedInfoRecord(url: URL, infoRecord: FileInfoRecord) {
        
        print("Saved", terminator: "")
        if infoRecord is RegularFileInfoRecord {
            print(" regular file", terminator: "")
        } else if infoRecord is DirectoryInfoRecord {
            print(" directory", terminator: "")
        }
        print(" \(url.relativePath(baseUrl: URL(dirPath: dirPath)))")
        
        if let creationDate = infoRecord.creationDateUtc {
            print(" date created: \(creationDate)")
        }
        if let modificationDate = infoRecord.modificationDateUtc {
            print(" date modified: \(modificationDate)")
        }
        if let accessDate = infoRecord.accessDateUtc {
            print (" date accessed: \(accessDate)")
        }
        if let fileInfoRecord = infoRecord as? RegularFileInfoRecord {
            if let size = fileInfoRecord.size {
                print(" size: \(size)")
            }
            if let sha512 = fileInfoRecord.sha512 {
                print(" SHA512: \(sha512)")
            }
        }
    }
    
}

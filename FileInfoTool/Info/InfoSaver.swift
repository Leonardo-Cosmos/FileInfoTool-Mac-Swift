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
    
    private let saveFileCreationTime: Bool
    
    private let saveFileLastWriteTime: Bool
    
    private let saveFileLastAccessTime: Bool
    
    private let saveFileSize: Bool
    
    private let saveFileHash: Bool
    
    private let dirAttributes: [InfoAttribute]
    
    private let saveDirCreationTime: Bool
    
    private let saveDirLastWriteTime: Bool
    
    private let saveDirLastAccessTime: Bool
    
    private var savedFileCount: Int
    
    private var savedDirectoryCount: Int
    
    init(dirPath: String, infoFilePath: String,
         fileAttributes: [InfoAttribute]?, dirAttributes: [InfoAttribute]?) {
        
        self.dirPath = dirPath
        self.infoFilePath = infoFilePath
        
        if let fileAttributes = fileAttributes {
            self.fileAttributes = fileAttributes.filter { attr in validaSaveFileAttributes.contains(attr) }
        } else {
            self.fileAttributes = [
                .CreationTime,
                .LastWriteTime,
                .LastAccessTime,
                .Size,
            ]
        }
        
        if let dirAttributes = dirAttributes {
            self.dirAttributes = dirAttributes.filter { attr in validDirProperties.contains(attr) }
        } else {
            self.dirAttributes = [
                .CreationTime,
                .LastWriteTime,
                .LastAccessTime,
            ]
        }
        
        saveFileCreationTime = self.fileAttributes.contains(.CreationTime)
        saveFileLastWriteTime = self.fileAttributes.contains(.LastWriteTime)
        saveFileLastAccessTime = self.fileAttributes.contains(.LastAccessTime)
        saveFileSize = self.fileAttributes.contains(.Size)
        saveFileHash = self.fileAttributes.contains(.Hash)
        
        saveDirCreationTime = self.dirAttributes.contains(.CreationTime)
        saveDirLastWriteTime = self.dirAttributes.contains(.LastWriteTime)
        saveDirLastAccessTime = self.dirAttributes.contains(.LastAccessTime)
        
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
            directories: \(savedDirectoryCount)
        """)
        
        let infoRecord = InfoRecord.create(dirInfoRecord: dirInfoRecord)
        
        try InfoSerializer.serialize(infoRecord: infoRecord, infoFilePath: infoFilePath)
    }
    
    private func save(dirUrl: URL, recursive: Bool) throws -> DirectoryInfoRecord {
        
        let dirInfoRecord = try saveInfoRecord(url:dirUrl) as! DirectoryInfoRecord
        
        var fileInfoRecord: [RegularFileInfoRecord] = []
        
        return dirInfoRecord
    }
    
    private func saveInfoRecord(url: URL) throws -> FileInfoRecord {
        
        var saveCreationTime = false;
        var saveLastWriteTime = false;
        var saveLastAccessTime = false;
        var saveSize = false;
        var saveHash = false;
        if url.hasDirectoryPath {
            savedDirectoryCount += 1
            
            saveCreationTime = saveDirCreationTime
            saveLastWriteTime = saveDirLastWriteTime
            saveLastAccessTime = saveDirLastAccessTime
            
        } else {
            savedFileCount += 1
            
            saveCreationTime = saveFileCreationTime
            saveLastWriteTime = saveFileLastWriteTime
            saveLastAccessTime = saveFileLastAccessTime
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
        if saveCreationTime {
            resourceKeys.insert(.creationDateKey)
        }
        if saveLastWriteTime {
            resourceKeys.insert(.contentModificationDateKey)
        }
        if saveLastAccessTime {
            resourceKeys.insert(.contentAccessDateKey)
        }
        if saveSize {
            resourceKeys.insert(.fileSizeKey)
        }
        
        let resourceValues = try url.resourceValues(forKeys: resourceKeys)
        
        if saveCreationTime {
            infoRecord.creationTimeUtc = resourceValues.creationDate?.ISO8601Format()
        }
        if saveLastWriteTime {
            infoRecord.lastWriteTimeUtc = resourceValues.contentModificationDate?.ISO8601Format()
        }
        if saveLastAccessTime {
            infoRecord.lastAccessTimeUtc = resourceValues.contentAccessDate?.ISO8601Format()
        }
        if saveSize {
            let fileInfoRecord = infoRecord as! RegularFileInfoRecord
            fileInfoRecord.size = resourceValues.fileSize
        }
        
        printSavedInfoRecord(url: url, infoRecord: infoRecord)
        return infoRecord
    }
    
    private func printSavedInfoRecord(url: URL, infoRecord: FileInfoRecord) {
        
        if infoRecord is RegularFileInfoRecord {
            print("Saved regular file")
        } else if infoRecord is DirectoryInfoRecord {
            print("Saved directory")
        }
        print(url.relativePath(baseUrl: URL(dirPath: dirPath)))
        if let creationDate = infoRecord.creationTimeUtc {
            print(" date created: \(creationDate)")
        }
        if let modificationDate = infoRecord.lastWriteTimeUtc {
            print(" date modified: \(modificationDate)")
        }
        if let accessDate = infoRecord.lastAccessTimeUtc {
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

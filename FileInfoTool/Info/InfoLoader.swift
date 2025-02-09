//
//  InfoLoader.swift
//  FileInfoTool
//
//  Created on 2025/02/04.
//

import Foundation

internal class InfoLoader {
    
    private let dirPath: String
    
    private let infoFilePath: String
    
    private let mode: Mode
    
    private let fileAttributes: [InfoAttribute]
    
    private let loadFileCreationDate: Bool
    
    private let loadFileModificationDate: Bool
    
    private let loadFileAccessDate: Bool
    
    private let loadFileSize: Bool
    
    private let loadFileHash: Bool
    
    private let dirAttributes: [InfoAttribute]
    
    private let loadDirCreationDate: Bool
    
    private let loadDirModificationDate: Bool
    
    private let loadDirAccessDate: Bool
    
    private var loadedFileCount: Int
    
    private var loadedDirectoryCount: Int
    
    private var checkedFileCount: Int
    
    private var checkedDirectoryCount: Int
    
    private var sameFileCount: Int
    
    private var sameDirectoryCount: Int
    
    private var changedFileCount: Int
    
    private var changedDirectoryCount: Int
    
    private var missingFileCount: Int
    
    private var missingDirectoryCount: Int
    
    private var unknownFileCount: Int
    
    private var unknownDirectoryCount: Int
    
    init(dirPath: String, infoFilePath: String, mode: Mode,
         fileAttributes: [InfoAttribute]?, dirAttributes: [InfoAttribute]?) {
        
        self.dirPath = dirPath
        self.infoFilePath = infoFilePath
        self.mode = mode
        
        if let fileAttributes = fileAttributes {
            if mode == .Restore {
                self.fileAttributes = fileAttributes.filter { attr in
                    validRestoreFileAttributes.contains(attr) }
            } else {
                self.fileAttributes = fileAttributes.filter { attr in
                    validFileAttributes.contains(attr) }
            }
        } else {
            if mode == .Restore {
                self.fileAttributes = [
                    .CreationDate,
                    .ModificationDate,
                ]
            } else {
                self.fileAttributes = [
                    .CreationDate,
                    .ModificationDate,
                    .Size
                ]
            }
        }
        
        if let dirAttributes = dirAttributes {
            self.dirAttributes = dirAttributes.filter { attr in validDirProperties.contains(attr) }
        } else {
            self.dirAttributes = [
                .CreationDate,
                .ModificationDate,
            ]
        }
        
        loadFileCreationDate = self.fileAttributes.contains(.CreationDate)
        loadFileModificationDate = self.fileAttributes.contains(.ModificationDate)
        loadFileAccessDate = self.fileAttributes.contains(.AccessDate)
        loadFileSize = self.fileAttributes.contains(.Size)
        loadFileHash = self.fileAttributes.contains(.Hash)
        
        loadDirCreationDate = self.dirAttributes.contains(.CreationDate)
        loadDirModificationDate = self.dirAttributes.contains(.ModificationDate)
        loadDirAccessDate = self.dirAttributes.contains(.AccessDate)
        
        loadedFileCount = 0
        loadedDirectoryCount = 0
        checkedFileCount = 0
        checkedDirectoryCount = 0
        sameFileCount = 0
        sameDirectoryCount = 0
        changedFileCount = 0
        changedDirectoryCount = 0
        missingFileCount = 0
        missingDirectoryCount = 0
        unknownFileCount = 0
        unknownDirectoryCount = 0
    }
    
    func load(recursive: Bool) throws {
        let fileAttributeNames = fileAttributes.map { attr in attr.nameString }
        let dirAttributeNames = dirAttributes.map { attr in attr.nameString }
        
        print("""
        Load file system info
            mode: \(mode.rawValue)
            directory: \(dirPath)
            recursive: \(recursive)
            info file: \(infoFilePath)
            file attributes: \(fileAttributeNames.joined(separator: ", "))
            directory attributes: \(dirAttributeNames.joined(separator: ", "))
        
        """)
        
        guard FileManager.default.fileExists(atPath: infoFilePath) else {
            throw RuntimeError.infoFileNotExists(infoFilePath)
        }
        
        let infoRecord = try InfoSerializer.deserialize(infoFilePath: infoFilePath)
        
        if mode == .List {
            loadedFileCount = 0
            loadedDirectoryCount = 0
            load(dirInfoRecord: infoRecord.directory, recursive: recursive)
            print("""
            Loaded
                file: \(loadedFileCount)
                directory: \(loadedDirectoryCount)
            """)
        } else {
            guard FileManager.default.fileExists(atPath: dirPath) else {
                throw RuntimeError.targetDirNotExists(dirPath)
            }
            
            changedFileCount = 0
            checkedDirectoryCount = 0
            changedFileCount = 0
            changedDirectoryCount = 0
            sameFileCount = 0
            sameDirectoryCount = 0
            missingFileCount = 0
            missingDirectoryCount = 0
            unknownFileCount = 0
            unknownDirectoryCount = 0
            let dirUrl = URL(dirPath: dirPath)
            load(dirUrl: dirUrl, dirInfoRecord: infoRecord.directory,
                 recursive: recursive, restore: mode == .Restore)
            print("""
            Checked
                file: \(checkedFileCount)
                directory: \(checkedDirectoryCount)
            Same
                file: \(sameFileCount)
                directory: \(sameDirectoryCount)
            Changed
                file: \(changedFileCount)
                directory: \(changedDirectoryCount)
            Missing
                file: \(missingFileCount)
                directory: \(missingDirectoryCount)
            Unknown
                file: \(unknownFileCount)
                directory: \(unknownDirectoryCount)
            """)
        }
    }
    
    private func load(dirInfoRecord: DirectoryInfoRecord, recursive: Bool) {
        if recursive {
            let subDirInfoRecords = dirInfoRecord.directories ?? []
            for subDirInfoRecord in subDirInfoRecords {
                // Set parent directory because it is not saved in info record file.
                subDirInfoRecord.directory = dirInfoRecord
                
                load(dirInfoRecord: subDirInfoRecord, recursive: recursive)
            }
        }
        
        let fileInfoRecords = dirInfoRecord.files ?? []
        for fileInfoRecord in fileInfoRecords {
            // Set parent directory because it is not saved in info record file.
            fileInfoRecord.directory = dirInfoRecord
            
            printLoadedInfoRecord(infoRecord: fileInfoRecord)
        }
        
        printLoadedInfoRecord(infoRecord: dirInfoRecord)
    }
    
    private func printLoadedInfoRecord(infoRecord: FileInfoRecord) {
        var loadCreationDate = false
        var loadModificationDate = false
        var loadAccessDate = false
        var loadSize = false
        var loadHash = false
        if infoRecord is RegularFileInfoRecord {
            loadCreationDate = loadFileCreationDate
            loadModificationDate = loadFileModificationDate
            loadAccessDate = loadFileAccessDate
            loadSize = loadFileSize
            loadHash = loadFileHash
            
            loadedFileCount += 1
        } else if infoRecord is DirectoryInfoRecord {
            loadCreationDate = loadDirCreationDate
            loadModificationDate = loadDirModificationDate
            loadAccessDate = loadDirAccessDate
            
            loadedDirectoryCount += 1
        }
        
        print("Loaded", terminator: "")
        if infoRecord is RegularFileInfoRecord {
            print(" regular file ", terminator: "")
        } else if infoRecord is DirectoryInfoRecord {
            print(" directory ", terminator: "")
        }
        print(" \(infoRecord.relativePath)")
        
        if loadCreationDate {
            print(" date created: \(infoRecord.creationDateUtc ?? "")")
        }
        if loadModificationDate {
            print(" date modified: \(infoRecord.modificationDateUtc ?? "")")
        }
        if loadAccessDate {
            print(" date accessed: \(infoRecord.accessDateUtc ?? "")")
        }
        if let fileInfoRecord = infoRecord as? RegularFileInfoRecord {
            if loadSize {
                print(" size: \(fileInfoRecord.size?.description ?? "")")
            }
            if loadHash {
                print(" SHA512: \(fileInfoRecord.sha512 ?? "")")
            }
        }
    }
    
    private func load(dirUrl: URL, dirInfoRecord: DirectoryInfoRecord,
                      recursive: Bool, restore: Bool) {
        
    }
    
    private func printUnknownInfo(url: URL) {
        if url.hasDirectoryPath {
            print("Unknown directory \(url.relativePath(baseUrl: URL(dirPath: dirPath)))")
            unknownDirectoryCount += 1
        } else {
            print("Unknown file \(url.relativePath(baseUrl: URL(dirPath: dirPath)))")
            unknownFileCount += 1
        }
    }
    
    private func printMissingInfoRecords(dirUrl: URL, infoRecords: [FileInfoRecord]) {
        
        for infoRecord in infoRecords {
            if infoRecord is RegularFileInfoRecord {
                let fileUrl = dirUrl.appending(fileNotDirPath: infoRecord.name)
                print("Missing file \(fileUrl.relativePath(baseUrl: URL(dirPath: dirPath)))")
                missingFileCount += 1
            } else if infoRecord is DirectoryInfoRecord {
                let subDirUrl = dirUrl.appending(dirPath: infoRecord.name)
                print("Missing directory: \(subDirUrl.relativePath(baseUrl: URL(dirPath: dirPath)))")
                missingDirectoryCount += 1
            }
        }
    }
    
    private func countDirectoryContent(dirUrl: URL) -> (Int, Int) {
        return (0, 0)
    }
    
    private func countDirectoryRecordContent(dirInfoRecord: DirectoryInfoRecord) -> (Int, Int) {
        return (0, 0)
    }
    
    
    private func printLoadedInfoRecord(url: URL, infoRecord: FileInfoRecord,
                                       restore: Bool, isChanged: Bool,
                                       changedCreationDateUtc: String?,
                                       changedModificationDateUtc: String?,
                                       changedAccessDateUtc: String?,
                                       changedFileSize: Int?,
                                       changedFileSHA512: String?) {
        
        if isChanged {
            if restore {
                print("Restored", terminator: "")
            } else {
                print("Detected", terminator: "")
            }
        } else {
            print("Same", terminator: "")
        }
        
        if infoRecord is RegularFileInfoRecord {
            print(" regular file")
            if isChanged {
                changedFileCount += 1
            } else {
                sameFileCount += 1
            }
        } else if infoRecord is DirectoryInfoRecord {
            print(" directory")
            if isChanged {
                changedDirectoryCount += 1
            } else {
                sameDirectoryCount += 1
            }
        }
        print(" \(url.relativePath(baseUrl: URL(dirPath: dirPath)))")
                
        if let changedCreationDateUtc = changedCreationDateUtc {
            print(" date created: \(infoRecord.creationDateUtc ?? "") -> \(changedCreationDateUtc)")
        }
        if let changedModificationDateUtc = changedModificationDateUtc {
            print(" date modified: \(infoRecord.modificationDateUtc ?? "") -> \(changedModificationDateUtc)")
        }
        if let changedAccessDateUtc = changedAccessDateUtc {
            print (" date accessed: \(infoRecord.accessDateUtc ?? "") -> \(changedAccessDateUtc)")
        }
        if let fileInfoRecord = infoRecord as? RegularFileInfoRecord {
            if let changedFileSize = changedFileSize {
                print(" size: \(fileInfoRecord.size?.description ?? "") -> \(changedFileSize)")
            }
            if let changedFileSHA512 = changedFileSHA512 {
                print(" SHA512: \(fileInfoRecord.sha512 ?? "") -> \(changedFileSHA512)")
            }
        }
    }
}

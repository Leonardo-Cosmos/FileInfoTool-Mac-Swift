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
            try load(dirUrl: dirUrl, dirInfoRecord: infoRecord.directory,
                 recursive: recursive, restore: mode == .Restore)
            
            print()
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
        
        let regularFileInfoRecords = dirInfoRecord.files ?? []
        for regularFileInfoRecord in regularFileInfoRecords {
            // Set parent directory because it is not saved in info record file.
            regularFileInfoRecord.directory = dirInfoRecord
            
            printLoadedInfoRecord(infoRecord: regularFileInfoRecord)
        }
        
        printLoadedInfoRecord(infoRecord: dirInfoRecord)
    }
    
    private func load(dirUrl: URL, dirInfoRecord: DirectoryInfoRecord,
                      recursive: Bool, restore: Bool) throws {
        var fileUrls: [URL]
        do {
            fileUrls = try FileManager.default.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            dirInfoRecord.getFilesFailed = true
            fileUrls = []
        }
        if recursive {
            let subDirInfoRecords = dirInfoRecord.directories ?? []
            var loadedSubDirInfoRecords: [DirectoryInfoRecord] = []
            let subDirectoryUrls = fileUrls.filter { url in url.hasDirectoryPath }
            for subDirectoryUrl in subDirectoryUrls {
                let subDirInfoRecord = subDirInfoRecords.first { infoRecord in infoRecord.name == subDirectoryUrl.lastPathComponent }
                if let subDirInfoRecord = subDirInfoRecord {
                    try load(dirUrl: subDirectoryUrl, dirInfoRecord: subDirInfoRecord, recursive: recursive, restore: restore)
                    loadedSubDirInfoRecords.append(subDirInfoRecord)
                } else {
                    printUnknownInfo(url: subDirectoryUrl)
                    let (subDirUnknownFileCount, subDirUnknownDirectoryCount) = countDirectoryContent(dirUrl: subDirectoryUrl)
                    unknownFileCount = unknownFileCount + subDirUnknownFileCount
                    unknownDirectoryCount = unknownDirectoryCount + subDirUnknownDirectoryCount
                }
            }
            
            let loadedSubDirNameSet = Set(loadedSubDirInfoRecords.map { infoRecord in infoRecord.name })
            let missingSubDirInfoRecords = subDirInfoRecords.filter { infoRecord in !loadedSubDirNameSet.contains(infoRecord.name) }
            printMissingInfoRecords(dirUrl: dirUrl, infoRecords: missingSubDirInfoRecords)
            for missingSubDirInfoRecord in missingSubDirInfoRecords {
                let (subDirMissingFileCount, subDirMissingDirectoryCount) = countDirectoryRecordContent(dirInfoRecord: missingSubDirInfoRecord)
                missingFileCount = missingFileCount + subDirMissingFileCount
                missingDirectoryCount = missingDirectoryCount + subDirMissingDirectoryCount
            }
        }
        
        let regularFileInfoRecords = dirInfoRecord.files ?? []
        var loadedRegularFileInfoRecords: [RegularFileInfoRecord] = []
        let regularFileUrls = fileUrls.filter { url in !url.hasDirectoryPath }
        for regularFileUrl in regularFileUrls {
            let regularFileInfoRecord = regularFileInfoRecords.first { infoRecord in infoRecord.name == regularFileUrl.lastPathComponent }
            if let regularFileInfoRecord = regularFileInfoRecord {
                try loadInfoRecord(url: regularFileUrl, infoRecord: regularFileInfoRecord, restore: restore)
                loadedRegularFileInfoRecords.append(regularFileInfoRecord)
            } else {
                printUnknownInfo(url: regularFileUrl)
            }
        }
        
        let loadedRegularFileNameSet = Set(loadedRegularFileInfoRecords.map { infoRecord in infoRecord.name })
        let missingRegularFileInfoRecords = regularFileInfoRecords.filter { infoRecord in !loadedRegularFileNameSet.contains(infoRecord.name) }
        printMissingInfoRecords(dirUrl: dirUrl, infoRecords: missingRegularFileInfoRecords)
        
        try loadInfoRecord(url: dirUrl, infoRecord: dirInfoRecord, restore: restore)
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
        var regularFileCount = 0
        var directoryCount = 0
        
        var fileUrls: [URL]
        do {
            fileUrls = try FileManager.default.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            fileUrls = []
        }
        
        let subDirUrls = fileUrls.filter { url in url.hasDirectoryPath }
        for subDirUrl in subDirUrls {
            let (subDirRegularFileCount, subDirDirectoryCount) = countDirectoryContent(dirUrl: subDirUrl)
            regularFileCount = regularFileCount + subDirRegularFileCount
            directoryCount = directoryCount + subDirDirectoryCount
        }
        directoryCount = directoryCount + subDirUrls.count
        
        let regularFileUrls = fileUrls.filter { url in !url.hasDirectoryPath }
        regularFileCount = regularFileCount + regularFileUrls.count
        
        return (regularFileCount, directoryCount)
    }
    
    private func countDirectoryRecordContent(dirInfoRecord: DirectoryInfoRecord) -> (Int, Int) {
        
        var regularFileCount = 0
        var directoryCount = 0
        
        let subDirInfoRecords = dirInfoRecord.directories ?? []
        for subDirInfoRecord in subDirInfoRecords {
            let (subDirRegularFileCount, subDirDirectoryCount) = countDirectoryRecordContent(dirInfoRecord: subDirInfoRecord)
            regularFileCount = regularFileCount + subDirRegularFileCount
            directoryCount = directoryCount + subDirDirectoryCount
        }
        directoryCount = directoryCount + subDirInfoRecords.count
        
        let regularFileInfoRecords = dirInfoRecord.files ?? []
        regularFileCount = regularFileCount + regularFileInfoRecords.count
        
        return (regularFileCount, directoryCount)
    }
    
    private func loadInfoRecord(url: URL, infoRecord: FileInfoRecord, restore: Bool) throws {
        var restoreUrl: URL
        var loadCreationDate = false
        var loadModificationDate = false
        var loadAccessDate = false
        var loadSize = false
        var loadHash = false
        if url.hasDirectoryPath {
            restoreUrl = URL(dirPath: url.standardPath)
            
            loadCreationDate = loadDirCreationDate
            loadModificationDate = loadDirModificationDate
            loadAccessDate = loadDirAccessDate
            
            checkedDirectoryCount = checkedDirectoryCount + 1
            
        } else {
            restoreUrl = URL(fileNotDirPath: url.standardPath)
            
            loadCreationDate = loadFileCreationDate
            loadModificationDate = loadFileModificationDate
            loadAccessDate = loadFileAccessDate
            loadSize = loadFileSize
            loadHash = loadFileHash
            
            checkedFileCount = checkedFileCount + 1
        }
        
        var resourceKeys: Set<URLResourceKey> = []
        if loadCreationDate {
            resourceKeys.insert(.creationDateKey)
        }
        if loadModificationDate {
            resourceKeys.insert(.contentModificationDateKey)
        }
        if loadAccessDate {
            resourceKeys.insert(.contentAccessDateKey)
        }
        if loadSize {
            resourceKeys.insert(.fileSizeKey)
        }
        
        let resourceValues = try url.resourceValues(forKeys: resourceKeys)
        var restoreResourceValues = URLResourceValues()
        let dateFormatter = ISO8601DateFormatter()
        
        var changedCreationDateUtc: String? = nil
        let isCreationDateChanged = loadCreationDate && Self.isDateChanged(date: resourceValues.creationDate, isoString: infoRecord.creationDateUtc)
        if isCreationDateChanged {
            changedCreationDateUtc = dateFormatter.string(from: resourceValues.creationDate!)
            if restore {
                restoreResourceValues.creationDate = dateFormatter.date(from: infoRecord.creationDateUtc!)
            }
        }
        
        var changedModificationDateUtc: String? = nil
        let isModificationDateChanged = loadModificationDate && Self.isDateChanged(date: resourceValues.contentModificationDate, isoString: infoRecord.modificationDateUtc)
        if isModificationDateChanged {
            changedModificationDateUtc = dateFormatter.string(from: resourceValues.contentModificationDate!)
            if restore {
                restoreResourceValues.contentModificationDate = dateFormatter.date(from: infoRecord.modificationDateUtc!)
            }
        }
        
        var changedAccessDateUtc: String? = nil
        let isAccessDateChanged = loadAccessDate && Self.isDateChanged(date: resourceValues.contentAccessDate, isoString: infoRecord.accessDateUtc)
        if isAccessDateChanged {
            changedAccessDateUtc = dateFormatter.string(from: resourceValues.contentAccessDate!)
            if restore {
                restoreResourceValues.contentAccessDate = dateFormatter.date(from: infoRecord.accessDateUtc!)
            }
        }
        
        var changedFileSize: Int? = nil
        var isFileSizeChanged = false
        if !restore && loadSize {
            let regularFileInfoRecord = infoRecord as! RegularFileInfoRecord
            if let recordSize = regularFileInfoRecord.size, let actualSize = resourceValues.fileSize {
                if recordSize != actualSize {
                    isFileSizeChanged = true
                    changedFileSize = actualSize
                }
            }
        }
        
        var changedFileSHA512: String? = nil
        var isFileHashChanged = false
        if !restore && loadHash {
            let regularFileInfoRecord = infoRecord as! RegularFileInfoRecord
            
            if let loadedSHA512 = regularFileInfoRecord.sha512 {
                let sha512 = calculateFileHash(fileUrl: url, regularFileInfoRecord: regularFileInfoRecord)
                
                if loadedSHA512 != sha512 {
                    isFileHashChanged = true
                    changedFileSHA512 = sha512
                }
            }
        }
        
        try restoreUrl.setResourceValues(resourceValues)
        
        let isChanged = isCreationDateChanged || isModificationDateChanged || isAccessDateChanged
        || isFileSizeChanged || isFileHashChanged
        
        printLoadedInfoRecord(url: url, infoRecord: infoRecord, restore: restore, isChanged: isChanged, changedCreationDateUtc: changedCreationDateUtc, changedModificationDateUtc: changedModificationDateUtc, changedAccessDateUtc: changedAccessDateUtc, changedFileSize: changedFileSize, changedFileSHA512: changedFileSHA512)
    }
    
    private static func isDateChanged(date: Date?, isoString: String?) -> Bool {
        if let date = date, let isoString = isoString {
            return date.ISO8601Format() != isoString
        } else {
            return false
        }
    }
    
    private func calculateFileHash(fileUrl: URL, regularFileInfoRecord: RegularFileInfoRecord) -> String {
        print("Hash \(fileUrl.relativePath(baseUrl: URL(dirPath: dirPath)))")
        let progressPrinter = ProgressPrinter(format: "%@ (%@ / %@), %@/s")
        var sha512 = ""
        do {
            sha512 = try HashComputer.computeSHA512(fileUrl: fileUrl) { hashProgress in
                progressPrinter.update(hashProgress.percentage,
                                       hashProgress.totalUpdatedLength.byteWithUnitString(),
                                       hashProgress.totalLength.byteWithUnitString(),
                                       hashProgress.lengthPerSecond)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            regularFileInfoRecord.computeHashFailed = true
        }
        
        defer {
            progressPrinter.end()
        }
        
        return sha512
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
        if let regularFileInfoRecord = infoRecord as? RegularFileInfoRecord {
            if loadSize {
                print(" size: \(regularFileInfoRecord.size?.byteWithUnitString() ?? "")")
            }
            if loadHash {
                print(" SHA512: \(regularFileInfoRecord.sha512 ?? "")")
            }
        }
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
        if let regularFileInfoRecord = infoRecord as? RegularFileInfoRecord {
            if let changedFileSize = changedFileSize {
                print(" size: \(regularFileInfoRecord.size?.byteWithUnitString() ?? "") -> \(changedFileSize.byteWithUnitString())")
            }
            if let changedFileSHA512 = changedFileSHA512 {
                print(" SHA512: \(regularFileInfoRecord.sha512 ?? "") -> \(changedFileSHA512)")
            }
        }
    }
}

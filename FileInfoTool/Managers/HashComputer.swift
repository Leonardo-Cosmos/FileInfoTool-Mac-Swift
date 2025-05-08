//
//  HashComputer.swift
//  FileInfoTool
//
//  Created on 2025/05/02.
//

import Foundation
import CryptoKit

internal class HashComputer {
    
    /// 4KB chunk length
    private static let chunkLength = 0x1000
    
    private static let minReportLoop = 2000
    
    /// 16MB
    private static let minReportLength = 0x1000000
    
    private static let minReportNanoseconds = 1_000_000_000
    
    static func computeSHA512(fileUrl: URL, reportProgress: ((HashProgress) -> Void)?) throws -> String {
        let fileHandle = try FileHandle(forReadingFrom: fileUrl)
        let fileSize = try fileHandle.seekToEnd()
        try fileHandle.seek(toOffset: 0)
        
        var hasher = SHA512()
        
        var totalReadLength: UInt64 = 0
        var progressReadLength: UInt64 = 0
        var progressLoopCount = 0
        var totalElapsedNanoseconds: UInt64 = 0
        var progressElapsedNanoseconds: UInt64 = 0
        let startTime = DispatchTime.now()
        while true {
            let data = fileHandle.readData(ofLength: chunkLength)
            if data.isEmpty {
                break
            }
            
            hasher.update(data: data)
            
            totalReadLength = totalReadLength + UInt64(data.count)
            progressReadLength = progressReadLength + UInt64(data.count)
            progressLoopCount = progressLoopCount + 1
            
            let progressTime = DispatchTime.now()
            progressElapsedNanoseconds = (progressTime.uptimeNanoseconds - startTime.uptimeNanoseconds) - totalElapsedNanoseconds
            if progressLoopCount >= minReportLoop && progressReadLength > minReportLength
                && progressElapsedNanoseconds > minReportNanoseconds {
                
                totalElapsedNanoseconds = (progressTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
                
                reportProgress?(HashProgress(totalLength: fileSize,
                                             totalUpdatedLength: totalReadLength,
                                             updatedLength: progressReadLength,
                                             elapsedNanoseconds: progressElapsedNanoseconds))
                
                progressReadLength = 0
                progressLoopCount = 0
            }
        }
        
        defer {
            fileHandle.closeFile()
        }
        
        let digest = hasher.finalize()
        let hashString = digest.map { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    internal struct HashProgress {
        let totalLength: UInt64
        let totalUpdatedLength: UInt64
        let updatedLength: UInt64
        let elapsedNanoseconds: UInt64
        
        var percentage: String {
            get {
                if totalLength == 0 {
                    return Decimal(1).percentageString()
                }
                let decimalValue = Decimal(totalUpdatedLength) / Decimal(totalLength)
                return decimalValue.percentageString()
            }
        }
        
        var lengthPerSecond: String {
            get {
                if elapsedNanoseconds == 0 {
                    return updatedLength.byteWithUnitString()
                }
                return (1_000_000_000 * updatedLength / elapsedNanoseconds).byteWithUnitString()
            }
        }
    }
}

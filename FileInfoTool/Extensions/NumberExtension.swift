//
//  NumberExtension.swift
//  FileInfoTool
//
//  Created on 2025/05/04.
//

import Foundation

extension UInt64 {
    
    private static let kilo: Decimal = 1000
    
    private static let units = [
        "B",
        "KB",
        "MB",
        "GB",
    ]
    
    private static let lastUnit = "TB"
    
    func byteWithUnitString() -> String {
        var number = Decimal(self)
        for unit in Self.units {
            if number < Self.kilo {
                return "\(number.byteDigitString())\(unit)"
            } else {
                number = number / Self.kilo
            }
        }
        return "\(number.byteDigitString())\(Self.lastUnit)"
    }
    
    func groupString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        return formatter.string(from: NSNumber(value: self))!
    }
    
    func byteDetailString() -> String {
        return "\(byteWithUnitString()) (\(groupString()) bytes)"
    }
}

extension Decimal {
    
    func byteDigitString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: self as NSDecimalNumber)!
    }
}

extension Int {
    
    func byteWithUnitString() -> String {
        return UInt64(self).byteWithUnitString()
    }
}

extension Decimal {
    
    func percentageString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: self as NSDecimalNumber)!
    }
}

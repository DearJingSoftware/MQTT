//
//  MQTTExtensions.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/6.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

extension Int: MQTTData {
    var mqttData: Data {
        /// 1.5.5 Variable Byte Integer
        var x = self
        var data = Data()
        repeat {
            var encodedByte = UInt8(x % 128)
            x = x / 128
            if x > 0 {
                encodedByte |= 128
            }
            data.append(encodedByte)
        } while x > 0
        return data
    }
}


extension UInt8: MQTTData {
    var mqttData: Data {
        var data = Data()
        data.append(self)
        return data
    }
}

extension UInt16: MQTTData {
    var mqttData: Data {
        var data = Data()
        let byte1 = UInt8(self >> 8 & 0x00ff)
        let byte2 = UInt8(self & 0x00ff)
        data.append(byte1)
        data.append(byte2)
        return data
    }
}

extension UInt32: MQTTData {
    var mqttData: Data {
        var data = Data()
        let byte1 = UInt8(self >> 24 & 0x0000_00ff)
        let byte2 = UInt8(self >> 16 & 0x0000_00ff)
        let byte3 = UInt8(self >> 8 & 0x0000_00ff)
        let byte4 = UInt8(self & 0x0000_00ff)
        data.append(byte1)
        data.append(byte2)
        data.append(byte3)
        data.append(byte4)
        return data
    }
}

extension Dictionary: MQTTData where Key: MQTTData, Value: MQTTData {
    var mqttData: Data {
        var data = Data()
        for (key, value) in self {
            let key = key as! String
            let value = value as! String
            data += key.mqttData
            data += value.mqttData
        }
        return data
    }
}

extension String: MQTTData {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    var mqttData: Data {
        var data = Data()
        let length = UInt16(self.count)
        data += length.mqttData
        data += self.data(using: .utf8)!
        return data
    }
    
}


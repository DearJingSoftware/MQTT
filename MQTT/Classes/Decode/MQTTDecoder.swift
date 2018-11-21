//
//  MQTTDecoder.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/9.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

class MQTTDecoder {
    
    init() {}
    
    /// IMPORTANT
    /// copy-on-write
    /// avoid writing to remainingData if possible
    
    func decodeTwoByteInteger(remainingData: Data, pointer: Int) -> (value: UInt16, newPointer: Int)? {
        var newPointer = pointer
        if newPointer + 1 > remainingData.count {
            return nil
        }
        var value: UInt16 = 0
        value += UInt16(remainingData[newPointer])
        newPointer += 1
        value = value << 8
        value += UInt16(remainingData[newPointer])
        newPointer += 1
        return (value, newPointer)
    }
    
    func decodeFourByteInteger(remainingData: Data, pointer: Int) -> (value: UInt32, newPointer: Int)? {
        var newPointer = pointer
        if newPointer + 3 > remainingData.count {
            return nil
        }
        var value: UInt32 = 0
        value += UInt32(remainingData[newPointer])
        newPointer += 1
        value = value << 8
        value += UInt32(remainingData[newPointer])
        newPointer += 1
        value = value << 8
        value += UInt32(remainingData[newPointer])
        newPointer += 1
        value = value << 8
        value += UInt32(remainingData[newPointer])
        newPointer += 1
        return (value, newPointer)
    }
    
    func decodeVariableByteInteger(remainingData: Data, pointer: Int) -> (value: Int, newPointer: Int) {
        var newPointer = pointer
        var count = 0
        var value: Int = 0
        while newPointer < remainingData.count {
            let newValue = Int(remainingData[newPointer] & 0b0111_1111) << count
            value += newValue
            if (remainingData[newPointer] & 0b1000_0000) == 0 || count >= 21 {
                /// Tail
                newPointer += 1
                break
            }
            newPointer += 1
            count += 7
        }
        return (value, newPointer)
    }
    
    func decodeUTF8EncodedString(remainingData: Data, pointer: Int) -> (value: String, newPointer: Int)? {
        var newPointer = pointer
        
        if newPointer + 1 > remainingData.count {
            return nil
        }
        /// Length is a Two Byte Integer
        var length: UInt16 = 0
        guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: newPointer) else {
            return nil
        }
        length = result.value
        newPointer = result.newPointer
        
        var stringData = Data()
        for _ in 0 ..< length {
            stringData.append(remainingData[newPointer])
            newPointer += 1
        }
        guard let value = String(data: stringData, encoding: .utf8) else {
            return nil
        }
        
        return (value, newPointer)
    }
    
    func decodeBinaryData(remainingData: Data, pointer: Int) -> (value: Data, newPointer: Int)? {
        var newPointer = pointer
        if newPointer + 1 > remainingData.count {
            return nil
        }
        /// Binary Data is represented by a Two Byte Integer length which indicates the number of data bytes
        var length: UInt16 = 0
        guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: newPointer) else {
            return nil
        }
        length = result.value
        newPointer = result.newPointer
        
        var value = Data()
        for _ in 0 ..< length {
            value.append(remainingData[newPointer])
            newPointer += 1
        }
        return (value, newPointer)
    }
    
}

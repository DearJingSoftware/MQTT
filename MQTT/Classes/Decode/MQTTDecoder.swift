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
        value += UInt16(remainingData[pointer])
        newPointer += 1
        value = value << 8
        value += UInt16(remainingData[pointer])
        newPointer += 1
        return (value, newPointer)
    }
    
    func decodeVariableByteInteger(remainingData: Data, pointer: Int) -> (value: UInt32, newPointer: Int) {
        var newPointer = pointer
        var count = 0
        var value: UInt32 = 0
        while pointer < remainingData.count {
            let newValue = UInt32(remainingData[pointer] & 0b0111_1111) << count
            newPointer += 1
            value += newValue
            if (remainingData[pointer] & 0b1000_0000) == 0 || count >= 21 {
                /// Tail
                break
            }
            count += 7
        }
        return (value, newPointer)
    }
    
    func decodeUTF8EncodedString(remainingData: Data, pointer: Int) -> (value: String, newPointer: Int)? {
        var newPointer = pointer
        
        if pointer + 1 > remainingData.count {
            return nil
        }
        /// Length is a Two Byte Integer
        var length: UInt16 = 0
        guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
            return nil
        }
        length = result.value
        newPointer = result.newPointer
        
        var stringData = Data()
        for _ in 0 ..< length {
            stringData.append(remainingData[pointer])
            newPointer += 1
        }
        guard let value = String(data: stringData, encoding: .utf8) else {
            return nil
        }
        
        return (value, newPointer)
    }
    
}

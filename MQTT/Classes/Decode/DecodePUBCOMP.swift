//
//  DecodePUBCOMP.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

extension MQTTDecoder {
    func decodePUBCOMP(remainingData: Data) -> MQTTPUBCOMP? {
        
        let totalCount = remainingData.count
        var pointer = 0
        var base = pointer
        
        var propertyLength: UInt32 = 0
        
        var packetIdentifier: UInt16
        var reasonString: String?
        var userProperties: [String: String]?
        
        
        /// Packet Identifier
        /// The Packet Identifier field is only present in PUBLISH packets where the QoS level is 1 or 2.
        /// UInt16
        if pointer + 1 > totalCount {
            return nil
        }
        packetIdentifier = 0
        packetIdentifier += UInt16(remainingData[pointer])
        pointer += 1
        packetIdentifier = packetIdentifier << 8
        packetIdentifier += UInt16(remainingData[pointer])
        pointer += 1
        
        /// PUBACK Reason Code
        if pointer + 1 > totalCount {
            return nil
        }
        guard let reasonCode = MQTTPUBCOMPReasonCode(rawValue: remainingData[pointer]) else {
            return nil
        }
        pointer += 1
        
        /// propertyLength
        while pointer < totalCount {
            propertyLength = propertyLength << 7
            propertyLength += UInt32(remainingData[pointer] & 0b0111_1111)
            if (remainingData[pointer] & 0b1000_0000) == 0 {
                /// Tail
                pointer += 1
                break
            }
            pointer += 1
        }
        base = pointer
        
        /// properties
        while pointer < base + Int(propertyLength) {
            /// Although the Property Identifier is defined as a Variable Byte Integer, in this version of the specification all of the Property Identifiers are one byte long.
            /// We implement it as a Variable Byte Integer.
            var type: UInt32 = 0
            while pointer < totalCount {
                type = type << 7
                type += UInt32(remainingData[pointer] & 0b0111_1111)
                pointer += 1
                if (remainingData[pointer] & 0b1000_0000) == 0 {
                    /// Tail
                    break
                }
            }
            guard let propertyType = MQTTPropertyType(rawValue: type) else {
                return nil
            }
            switch propertyType {
            case .reasonString:
                /// String
                if pointer + 1 > totalCount {
                    return nil
                }
                /// Length is a Two Byte Integer
                var length: UInt16 = 0
                length += UInt16(remainingData[pointer])
                pointer += 1
                length = length << 8
                length += UInt16(remainingData[pointer])
                pointer += 1
                
                reasonString = ""
                for _ in 0 ..< length {
                    reasonString! += String(remainingData[pointer])
                    pointer += 1
                }
            case .userProperty:
                /// [String: String]
                /// String1
                var string1 = ""
                if pointer + 1 > totalCount {
                    return nil
                }
                /// Length is a Two Byte Integer
                var length: UInt16 = 0
                length += UInt16(remainingData[pointer])
                pointer += 1
                length = length << 8
                length += UInt16(remainingData[pointer])
                pointer += 1
                for _ in 0 ..< length {
                    string1 += String(remainingData[pointer])
                    pointer += 1
                }
                /// String2
                var string2 = ""
                if pointer + 1 > totalCount {
                    return nil
                }
                /// Length is a Two Byte Integer
                length = 0
                length += UInt16(remainingData[pointer])
                pointer += 1
                length = length << 8
                length += UInt16(remainingData[pointer])
                pointer += 1
                for _ in 0 ..< length {
                    string2 += String(remainingData[pointer])
                    pointer += 1
                }
                
                userProperties![string1] = string2
                
            default:
                return nil
            }
        }
        
        
        let packet = MQTTPUBCOMP(packetIdentifier: packetIdentifier, reasonCode: reasonCode)
        packet.reasonString = reasonString
        packet.userProperties = userProperties
        return packet
        
    }
}

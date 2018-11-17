//
//  DecodeDISCONNECT.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

extension MQTTDecoder {
    func decodeDISCONNECT(remainingData: Data) -> MQTTDISCONNECT? {
        let totalCount = remainingData.count
        
        var pointer = 0
        var base = pointer
        
        var propertyLength: UInt32 = 0
        var reasonCode: MQTTDISCONNECTReasonCode
        var sessionExpiryInterval: UInt32?
        var reasonString: String?
        var userProperties: [String: String]?
        var serverReference: String?
        
        /// reasonCode
        guard let code = MQTTDISCONNECTReasonCode(rawValue: remainingData[pointer]) else {
            return nil
        }
        reasonCode = code
        pointer += 1
        
        /// propertyLength
        let (value, newPointer) = decodeVariableByteInteger(remainingData: remainingData, pointer: pointer)
        propertyLength = value
        pointer = newPointer
        base = pointer
        
        /// properties
        while pointer < base + Int(propertyLength) {
            /// Although the Property Identifier is defined as a Variable Byte Integer, in this version of the specification all of the Property Identifiers are one byte long.
            /// We implement it as a Variable Byte Integer.
            var type: UInt32 = 0
            let (value, newPointer) = decodeVariableByteInteger(remainingData: remainingData, pointer: pointer)
            type = value
            pointer = newPointer
            guard let propertyType = MQTTPropertyType(rawValue: type) else {
                return nil
            }
            switch propertyType {
            case .sessionExpiryInterval:
                /// UInt32
                if pointer + 3 > totalCount {
                    return nil
                }
                sessionExpiryInterval = 0
                sessionExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
                sessionExpiryInterval = sessionExpiryInterval! << 8
                sessionExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
                sessionExpiryInterval = sessionExpiryInterval! << 8
                sessionExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
                sessionExpiryInterval = sessionExpiryInterval! << 8
                sessionExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
            case .reasonString:
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                reasonString = result.value
                pointer = result.newPointer
            case .userProperty:
                /// [String: String]
                /// String1
                var string1 = ""
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                string1 = result.value
                pointer = result.newPointer
                /// String2
                var string2 = ""
                guard let result2 = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                string2 = result2.value
                pointer = result2.newPointer
                
                userProperties![string1] = string2
                
            case .serverReference:
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                serverReference = result.value
                pointer = result.newPointer
            default:
                return nil
            }
        }
        
        let packet = MQTTDISCONNECT(reasonCode: reasonCode)
        packet.sessionExpiryInterval = sessionExpiryInterval
        packet.reasonString = reasonString
        packet.userProperties = userProperties
        packet.serverReference = serverReference
        
        return packet
        
    }
}

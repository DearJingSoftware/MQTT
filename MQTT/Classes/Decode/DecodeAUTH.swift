//
//  DecodeAUTH.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

extension MQTTDecoder {
    func decodeAUTH(remainingData: Data) -> MQTTAUTH? {
        
        var pointer = 0
        var base = pointer
        
        var propertyLength: Int = 0
        var reasonCode: MQTTAUTHReasonCode
        var authenticationMethod: String?
        var authenticationData: Data?
        var reasonString: String?
        var userProperties: [String: String]?
        
        /// reasonCode
        guard let code = MQTTAUTHReasonCode(rawValue: remainingData[pointer]) else {
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
            var type: Int = 0
            let (value, newPointer) = decodeVariableByteInteger(remainingData: remainingData, pointer: pointer)
            type = value
            pointer = newPointer
            guard let propertyType = MQTTPropertyType(rawValue: type) else {
                return nil
            }
            switch propertyType {
            case .authenticationMethod:
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                authenticationMethod = result.value
                pointer = result.newPointer
            case .authenticationData:
                /// Binary Data
                guard let result = decodeBinaryData(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                authenticationData = result.value
                pointer = result.newPointer
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
                
            default:
                return nil
            }
        }
        
        let packet = MQTTAUTH(reasonCode: reasonCode)
        packet.authenticationMethod = authenticationMethod
        packet.authenticationData = authenticationData
        packet.reasonString = reasonString
        packet.userProperties = userProperties
        
        return packet
        
    }
}

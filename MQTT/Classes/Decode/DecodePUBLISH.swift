//
//  DecodePUBLISH.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

extension MQTTDecoder {
    func decodePUBLISH(fixedHeaderData: Data, remainingData: Data) -> MQTTPUBLISH? {
        
        guard let byte1 = fixedHeaderData.first else {
            return nil
        }
        let dup = (byte1 & 0b0000_1000 >> 3) > 0
        guard let qos = MQTTQoS(rawValue: (byte1 & 0b0000_0110) >> 1) else {
            return nil
        }
        let retain = byte1 & 0b0000_0001 > 0
        
        let totalCount = remainingData.count
        var pointer = 0
        var base = pointer
        
        var propertyLength: UInt32 = 0
        var topicName = ""
        var packetIdentifier: UInt16?
        var payloadFormatIndicator: PayloadFormatIndicator?
        var messageExpiryInterval: UInt32?
        var topicAlias: UInt16?
        var responseTopic: String?
        var correlationData: Data?
        var userProperties: [String: String]?
        var subscriptionIdentifier: Int?
        var contentType: String?
        var applicationMessage: Data?
        
        /// Topic Name
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
        var stringData = Data()
        for _ in 0 ..< length {
            stringData.append(remainingData[pointer])
            pointer += 1
        }
        topicName = String(data: stringData, encoding: .utf8) ?? ""
        
        /// Packet Identifier
        /// The Packet Identifier field is only present in PUBLISH packets where the QoS level is 1 or 2.
        if qos == .qos1 || qos == .qos2 {
            /// Two Byte Integer
            guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
                return nil
            }
            packetIdentifier = result.value
            pointer = result.newPointer
        }
        
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
            case .payloadFormatIndicator:
                /// UInt8
                if pointer > totalCount {
                    return nil
                }
                if remainingData[pointer] & 0b0000_0001 > 0 {
                    payloadFormatIndicator = .utf8
                } else {
                    payloadFormatIndicator = .unspecified
                }
                pointer += 1
            case .messageExpiryInterval:
                /// UInt32
                if pointer + 3 > totalCount {
                    return nil
                }
                messageExpiryInterval = 0
                messageExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
                messageExpiryInterval = messageExpiryInterval! << 8
                messageExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
                messageExpiryInterval = messageExpiryInterval! << 8
                messageExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
                messageExpiryInterval = messageExpiryInterval! << 8
                messageExpiryInterval! += UInt32(remainingData[pointer])
                pointer += 1
            case .topicAlias:
                /// Two Byte Integer
                guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                topicAlias = result.value
                pointer = result.newPointer
            case .responseTopic:
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
                
                responseTopic = ""
                for _ in 0 ..< length {
                    responseTopic! += String(remainingData[pointer])
                    pointer += 1
                }
            case .correlationData:
                /// Data
                /// Binary Data is represented by a Two Byte Integer length which indicates the number of data bytes
                if pointer + 1 > totalCount {
                    return nil
                }
                var length: UInt16 = 0
                length += UInt16(remainingData[pointer])
                pointer += 1
                length = length << 8
                length += UInt16(remainingData[pointer])
                pointer += 1
                
                for _ in 0 ..< length {
                    correlationData?.append(remainingData[pointer])
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
                
            case .subscriptionIdentifier:
                /// Variable Byte Integer
                subscriptionIdentifier = 0
                let (value, newPointer) = decodeVariableByteInteger(remainingData: remainingData, pointer: pointer)
                subscriptionIdentifier = Int(value)
                pointer = newPointer
                
            case .contentType:
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
                
                contentType = ""
                for _ in 0 ..< length {
                    contentType! += String(remainingData[pointer])
                    pointer += 1
                }
                
            default:
                return nil
            }
        }
        if pointer < totalCount {
            applicationMessage = Data()
            while pointer < totalCount {
                applicationMessage?.append(remainingData[pointer])
                pointer += 1
            }
        }
        
        
        let packet = MQTTPUBLISH(topic: topicName)
        packet.dup = dup
        packet.qos = qos
        packet.retain = retain
        packet.packetIdentifier = packetIdentifier
        packet.payloadFormatIndicator = payloadFormatIndicator
        packet.messageExpiryInterval = messageExpiryInterval
        packet.topicAlias = topicAlias
        packet.responseTopic = responseTopic
        packet.correlationData = correlationData
        packet.userProperty = userProperties
        packet.subscriptionIdentifier = subscriptionIdentifier
        packet.contentType = contentType
        packet.applicationMessage = applicationMessage
        return packet
        
    }
}

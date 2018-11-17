//
//  DecodeCONNACK.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

extension MQTTDecoder {
    func decodeCONNACK(remainingData: Data) -> MQTTCONNACK? {
        let totalCount = remainingData.count
        
        var pointer = 0
        var base = pointer
        
        var sessionPresent: Bool
        var reasonCode: MQTTCONNACKReasonCode
        var propertyLength: UInt32 = 0
        var sessionExpiryInterval: UInt32?
        var receiveMaximum: UInt16?
        var maximumQoS: MQTTCONNACKMaximumQoS?
        var retain: Bool?
        var maximumPacketSize: UInt32?
        var assignedClientIdentifier: String?
        var topicAliasMaximum: UInt16?
        var reasonString: String?
        var userProperties: [String: String]?
        var wildcardSubscriptionAvailable: Bool?
        var subscriptionIdentifiersAvailable: Bool?
        var sharedSubscriptionAvailable: Bool?
        var serverKeepAlive: UInt16?
        var responseInformation: String?
        var serverReference: String?
        var authenticationMethod: String?
        var authenticationData: Data?
        
        /// sessionPresent
        /// Bit 0 is the Session Present Flag.
        sessionPresent = remainingData[pointer] & 0b0000_0001 > 0
        pointer += 1
        
        /// reasonCode
        guard let code = MQTTCONNACKReasonCode(rawValue: remainingData[pointer]) else {
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
            case .receiveMaximum:
                /// Two Byte Integer
                guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                receiveMaximum = result.value
                pointer = result.newPointer
            case .maximumQoS:
                /// UInt8
                if pointer > totalCount {
                    return nil
                }
                if remainingData[pointer] & 0b0000_0001 > 0 {
                    maximumQoS = .qos0
                } else {
                    maximumQoS = .qos1
                }
                pointer += 1
            case .retainAvailable:
                /// UInt8
                if pointer > totalCount {
                    return nil
                }
                if remainingData[pointer] & 0b0000_0001 > 0 {
                    retain = true
                } else {
                    retain = false
                }
                pointer += 1
            case .maximumPacketSize:
                /// UInt32
                if pointer + 3 > totalCount {
                    return nil
                }
                maximumPacketSize = 0
                maximumPacketSize! += UInt32(remainingData[pointer])
                pointer += 1
                maximumPacketSize = maximumPacketSize! << 8
                maximumPacketSize! += UInt32(remainingData[pointer])
                pointer += 1
                maximumPacketSize = maximumPacketSize! << 8
                maximumPacketSize! += UInt32(remainingData[pointer])
                pointer += 1
                maximumPacketSize = maximumPacketSize! << 8
                maximumPacketSize! += UInt32(remainingData[pointer])
                pointer += 1
            case .assignedClientIdentifier:
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
                
                assignedClientIdentifier = ""
                for _ in 0 ..< length {
                    assignedClientIdentifier! += String(remainingData[pointer])
                    pointer += 1
                }
            case .topicAliasMaximum:
                /// Two Byte Integer
                guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                topicAliasMaximum = result.value
                pointer = result.newPointer
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
                /// String
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
                
            case .wildcardSubscriptionAvailable:
                /// UInt8
                if pointer > totalCount {
                    return nil
                }
                if remainingData[pointer] & 0b0000_0001 > 0 {
                    wildcardSubscriptionAvailable = true
                } else {
                    wildcardSubscriptionAvailable = false
                }
                pointer += 1
            case .subscriptionIdentifiersAvailable:
                /// UInt8
                if pointer > totalCount {
                    return nil
                }
                if remainingData[pointer] & 0b0000_0001 > 0 {
                    subscriptionIdentifiersAvailable = true
                } else {
                    subscriptionIdentifiersAvailable = false
                }
                pointer += 1
            case .sharedSubscriptionAvailable:
                /// UInt8
                if pointer > totalCount {
                    return nil
                }
                if remainingData[pointer] & 0b0000_0001 > 0 {
                    sharedSubscriptionAvailable = true
                } else {
                    sharedSubscriptionAvailable = false
                }
                pointer += 1
            case .serverKeepAlive:
                /// Two Byte Integer
                guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                serverKeepAlive = result.value
                pointer = result.newPointer
            case .responseInformation:
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
                
                responseInformation = ""
                for _ in 0 ..< length {
                    responseInformation! += String(remainingData[pointer])
                    pointer += 1
                }
            case .serverReference:
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
                
                serverReference = ""
                for _ in 0 ..< length {
                    serverReference! += String(remainingData[pointer])
                    pointer += 1
                }
            case .authenticationMethod:
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
                
                authenticationMethod = ""
                for _ in 0 ..< length {
                    authenticationMethod! += String(remainingData[pointer])
                    pointer += 1
                }
            case .authenticationData:
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
                    authenticationData?.append(remainingData[pointer])
                    pointer += 1
                }
                
            default:
                return nil
            }
        }
        
        let packet = MQTTCONNACK(reasonCode: reasonCode)
        packet.sessionPresent = sessionPresent
        packet.sessionExpiryInterval = sessionExpiryInterval
        packet.receiveMaximum = receiveMaximum
        packet.maximumQoS = maximumQoS
        packet.retain = retain
        packet.maximumPacketSize = maximumPacketSize
        packet.assignedClientIdentifier = assignedClientIdentifier
        packet.topicAliasMaximum = topicAliasMaximum
        packet.reasonString = reasonString
        packet.userProperties = userProperties
        packet.wildcardSubscriptionAvailable = wildcardSubscriptionAvailable
        packet.subscriptionIdentifiersAvailable = subscriptionIdentifiersAvailable
        packet.sharedSubscriptionAvailable = sharedSubscriptionAvailable
        packet.serverKeepAlive = serverKeepAlive
        packet.responseInformation = responseInformation
        packet.serverReference = serverReference
        packet.authenticationMethod = authenticationMethod
        packet.authenticationData = authenticationData
        
        return packet
        
    }
}

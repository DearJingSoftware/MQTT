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
        var propertyLength: Int = 0
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
            var type: Int = 0
            let (value, newPointer) = decodeVariableByteInteger(remainingData: remainingData, pointer: pointer)
            type = value
            pointer = newPointer
            guard let propertyType = MQTTPropertyType(rawValue: type) else {
                return nil
            }
            switch propertyType {
            case .sessionExpiryInterval:
                /// Four Byte Integer
                guard let result = decodeFourByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                sessionExpiryInterval = result.value
                pointer = result.newPointer
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
                /// Four Byte Integer
                guard let result = decodeFourByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                maximumPacketSize = result.value
                pointer = result.newPointer
            case .assignedClientIdentifier:
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                assignedClientIdentifier = result.value
                pointer = result.newPointer
            case .topicAliasMaximum:
                /// Two Byte Integer
                guard let result = decodeTwoByteInteger(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                topicAliasMaximum = result.value
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
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                responseInformation = result.value
                pointer = result.newPointer
            case .serverReference:
                /// UTF8 Encoded String
                guard let result = decodeUTF8EncodedString(remainingData: remainingData, pointer: pointer) else {
                    return nil
                }
                serverReference = result.value
                pointer = result.newPointer
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

//
//  MQTTCONNECT.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/6.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

/// 3.1 CONNECT – Connection Request
public class MQTTCONNECT: MQTTProtocol {
    
    private var connectFlags: UInt8 = 0
    
    
    var _mqttWillMessage: MQTTWillMessage?
    var mqttWillMessage: MQTTWillMessage? {
        get {
            return self._mqttWillMessage
        }
        set {
            if let mqttWillMessage = newValue {
                /// 3.1.2.5 Will Flag
                self._mqttWillMessage = mqttWillMessage
                self.connectFlags |= 0b0000_0100
                /// 3.1.2.6 Will QoS
                /// If the Will Flag is set to 1, the value of Will QoS can be 0 (0x00), 1 (0x01), or 2 (0x02) [MQTT-3.1.2-12].
                switch mqttWillMessage.willQoS {
                case .qos0:
                    self.connectFlags &= 0b1110_0111
                case .qos1:
                    self.connectFlags &= 0b1110_1111
                    self.connectFlags |= 0b0000_1000
                case .qos2:
                    self.connectFlags |= 0b0001_0000
                    self.connectFlags &= 0b1111_0111
                }
                /// 3.1.2.7 Will Retain
                switch mqttWillMessage.willRetain {
                case true:
                    self.connectFlags |= 0b0010_0000
                case false:
                    self.connectFlags &= 0b1101_1111
                }
            } else {
                self._mqttWillMessage = newValue
                /// If the Will Flag is set to 0, then the Will QoS MUST be set to 0 (0x00) [MQTT-3.1.2-11].
                /// If the Will Flag is set to 0, then Will Retain MUST be set to 0 [MQTT-3.1.2-13].
                self.connectFlags &= 0b1100_0011
            }
        }
    }
    
    /// Part3 Payload
    /// These fields, if present, MUST appear in the order Client Identifier, Will Properties, Will Topic, Will Payload, User Name, Password
    /// Part3.1 Client ID.
    var clientID: String
    /// Part3.2 Will Properties
    var willDelayInterval: Int? // 0x18 4-byte
    var payloadFormatIndicator: UInt8?
    var messageExpiryInterval: UInt32?
    var contentType: String?
    var responseTopic: String?
    var correlationData: Data?
    var willUserProperties: [String: String]?
    /// Part3.3 Will Topic
    var willTopic: String?
    /// Part3.4 Will Payload
    var willPayload: Data?
    
    /// 3.1.2.8 User Name Flag
    var _username: String?
    var username: String? {
        get {
            return self._username
        }
        set {
            if let username = newValue {
                self._username = username
                self.connectFlags |= 0b1000_0000
            } else {
                self._username = newValue
                self.connectFlags &= 0b0111_1111
            }
        }
    }
    
    /// 3.1.2.9 Password Flag
    var _password: String?
    var password: String? {
        get {
            return self._password
        }
        set {
            if let password = newValue {
                self._password = password
                self.connectFlags |= 0b0100_0000
            } else {
                self._password = newValue
                self.connectFlags &= 0b1011_1111
            }
        }
    }
    
    /// 3.1.2.10 Keep Alive
    var keepAlive: UInt16 = 10
    
    /// 3.1.2.4 Clean Start
    var cleanStart: Bool {
        get {
            return self.connectFlags & 0b0000_0010 > 0
        }
        set {
            switch newValue {
            case true:
                self.connectFlags |= 0b0000_0010
            case false:
                self.connectFlags &= 0b1111_1101
            }
        }
    }
    
    var sessionExpiryInterval: UInt32?
    var receiveMaximum: UInt16?
    var maximumPacketSize: UInt32?
    var topicAliasMaximum: UInt16?
    var requestResponseInformation: UInt8?
    var requestProblemInfomation: UInt8?
    var userProperties: [String: String]?
    var authenticationMethod: String?
    var authenticationData: Data?
    
    init(clientID: String) {
        self.clientID = clientID
    }
    
    var mqttData: Data {
        /// 3.1.1 CONNECT Fixed Header
        /// Type+Flags to 1 byte
        var connectFixedHeader = Data()
        let type = MQTTType.CONNECT
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        connectFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        
        
        var remainingData = Data()
        
        /// 3.1.2 CONNECT Variable Header
        var variableHeaderData = Data()
        /// 3.1.2.1 Protocol Name
        let protocolName = MQTTProtocolName().mqttData
        variableHeaderData += protocolName
        /// 3.1.2.2 Protocol Version
        let protocolVersion = MQTTProtocolVersion().mqttData
        variableHeaderData.append(protocolVersion)
        /// 3.1.2.3 Connect Flags
        variableHeaderData.append(connectFlags)
        variableHeaderData += keepAlive.mqttData
        
        /// 3.1.2.11 CONNECT Properties
        var propertiesData = Data()
        /// 3.1.2.11.2 Session Expiry Interval
        if let sessionExpiryInterval = self.sessionExpiryInterval {
            propertiesData += MQTTProperty<UInt32>(.sessionExpiryInterval, value: sessionExpiryInterval).mqttData
        }
        /// 3.1.2.11.3 Receive Maximum
        if let receiveMaximum = self.receiveMaximum {
            propertiesData += MQTTProperty<UInt16>(.receiveMaximum, value: receiveMaximum).mqttData
        }
        /// 3.1.2.11.4 Maximum Packet Size
        if let maximumPacketSize = self.maximumPacketSize {
            propertiesData += MQTTProperty<UInt32>(.maximumPacketSize, value: maximumPacketSize).mqttData
        }
        /// 3.1.2.11.5 Topic Alias Maximum
        if let topicAliasMaximum = self.topicAliasMaximum {
            propertiesData += MQTTProperty<UInt16>(.topicAliasMaximum, value: topicAliasMaximum).mqttData
        }
        /// 3.1.2.11.6 Request Response Information
        if let requestResponseInformation = self.requestResponseInformation {
            propertiesData += MQTTProperty<UInt8>(.requestResponseInformation, value: requestResponseInformation).mqttData
        }
        /// 3.1.2.11.7 Request Problem Information
        if let requestProblemInfomation = self.requestProblemInfomation {
            propertiesData += MQTTProperty<UInt8>(.requestProblemInfomation, value: requestProblemInfomation).mqttData
        }
        /// 3.1.2.11.8 User Property
        if let userProperty = self.userProperties {
            propertiesData += MQTTProperty<[String : String]>(.userProperty, value: userProperty).mqttData
        }
        /// 3.1.2.11.9 Authentication Method
        if let authenticationMethod = self.authenticationMethod {
            propertiesData += MQTTProperty<String>(.authenticationMethod, value: authenticationMethod).mqttData
        }
        /// 3.1.2.11.10 Authentication Data
        if let authenticationData = self.authenticationData {
            propertiesData += authenticationData
        }
        
        /// 3.1.2.11.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        remainingData += variableHeaderData
        
        /// 3.1.3 CONNECT Payload
        var payloadData = Data()
        /// 3.1.3.1 Client Identifier (ClientID)
        payloadData += clientID.mqttData
        /// If the Will Flag is set to 1, then it will trigger 3.1.3.2 && 3.1.3.3 && 3.1.3.4
        if let willMessage = self.mqttWillMessage {
            /// 3.1.3.2 Will Properties
            payloadData += willMessage.mqttData
            /// 3.1.3.3 Will Topic
            payloadData += willMessage.willTopic.mqttData
            /// 3.1.3.4 Will Payload
            payloadData += willMessage.willPayload
        }
        /// 3.1.3.5 User Name
        if let username = self.username {
            payloadData += username.mqttData
        }
        /// 3.1.3.6 Password
        if let password = self.password {
            payloadData += password.mqttData
        }
        remainingData += payloadData
        
        var completeData = Data()
        completeData.append(connectFixedHeader)
        completeData += remainingData.count.mqttData
        completeData.append(remainingData)
        return completeData
    }
    
}

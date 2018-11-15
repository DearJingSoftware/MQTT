//
//  MQTTPUBLISH.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/6.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

/// 3.3 PUBLISH – Publish message
class MQTTPUBLISH: MQTTProtocol {
    
    /// 3.3.1.1 DUP
    var dup: Bool = false
    
    /// 3.3.1.2 QoS
    var qos: MQTTQoS = .qos2
    
    /// 3.3.1.3 RETAIN
    var retain: Bool = false
    
    var topic: String
    var packetIdentifier: UInt16?
    var payloadFormatIndicator: PayloadFormatIndicator?
    var messageExpiryInterval: UInt32?
    var topicAlias: UInt16?
    var responseTopic: String?
    var correlationData: Data?
    var userProperty: [String: String]?
    var subscriptionIdentifier: Int?
    var contentType: String?
    var applicationMessage: Data?
    
    init(topic: String) {
        self.topic = topic
    }
    
    var mqttData: Data {
        /// 3.3.1 PUBLISH Fixed Header
        /// Type+Flags to 1 byte
        var connectFixedHeader = Data()
        let type = MQTTType.PUBLISH
        // Reserved
        var flags: UInt8 = 0
        if dup {
            flags = flags | 0b0000_1000
        } else {
            flags = flags & 0b1111_0111
        }
        switch qos {
        case .qos0:
            flags = flags & 0b1111_1001
        case .qos1:
            flags = flags & 0b1111_1011
            flags = flags | 0b0000_0010
        case .qos2:
            flags = flags | 0b0000_0100
            flags = flags & 0b1111_1101
        }
        connectFixedHeader.append(type.rawValue << 4 + flags)
        
        var remainingData = Data()
        
        /// 3.3.2 PUBLISH Variable Header
        var variableHeaderData = Data()
        /// 3.3.2.1 Topic Name
        variableHeaderData += topic.mqttData
        /// 3.3.2.2 Packet Identifier
        if qos == .qos1 || qos == .qos2 {
            if let packetIdentifier = self.packetIdentifier {
                variableHeaderData += packetIdentifier.mqttData
            }
        }
        
        /// 3.3.2.3 PUBLISH Properties
        var propertiesData = Data()
        /// 3.3.2.3.2 Payload Format Indicator
        if let payloadFormatIndicator = self.payloadFormatIndicator {
            propertiesData += MQTTProperty<UInt8>(.payloadFormatIndicator, value: payloadFormatIndicator.rawValue).mqttData
        }
        /// 3.3.2.3.3 Message Expiry Interval
        if let messageExpiryInterval = self.messageExpiryInterval {
            propertiesData += MQTTProperty<UInt32>(.messageExpiryInterval, value: messageExpiryInterval).mqttData
        }
        /// 3.3.2.3.4 Topic Alias
        if let topicAlias = self.topicAlias {
            propertiesData += MQTTProperty<UInt16>(.topicAlias, value: topicAlias).mqttData
        }
        /// 3.3.2.3.5 Response Topic
        if let responseTopic = self.responseTopic {
            propertiesData += MQTTProperty<String>(.responseTopic, value: responseTopic).mqttData
        }
        /// 3.3.2.3.6 Correlation Data
        if let correlationData = self.correlationData {
            propertiesData += correlationData
        }
        /// 3.3.2.3.7 User Property
        if let userProperty = self.userProperty {
            propertiesData += MQTTProperty<[String: String]>(.userProperty, value: userProperty).mqttData
        }
        /// 3.3.2.3.8 Subscription Identifier
        if let subscriptionIdentifier = self.subscriptionIdentifier {
            propertiesData += MQTTProperty<Int>(.subscriptionIdentifier, value: subscriptionIdentifier).mqttData
        }
        /// 3.3.2.3.9 Content Type
        if let contentType = self.contentType {
            propertiesData += MQTTProperty<String>(.contentType, value: contentType).mqttData
        }
        
        /// 3.3.2.3.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        remainingData += variableHeaderData
        
        /// 3.3.3 PUBLISH Payload
        var payloadData = Data()
        if let applicationMessage = self.applicationMessage {
            payloadData += applicationMessage
        }
        remainingData += payloadData
        
        var completeData = Data()
        completeData.append(connectFixedHeader)
        completeData += remainingData.count.mqttData
        completeData.append(remainingData)
        return completeData
    }
    
}

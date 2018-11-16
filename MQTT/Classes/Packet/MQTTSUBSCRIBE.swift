//
//  MQTTSUBSCRIBE.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.8 SUBSCRIBE - Subscribe request
public class MQTTSUBSCRIBE: MQTTProtocol {
    
    public var packetIdentifier: UInt16
    public var subscriptionIdentifier: Int?
    public var userProperty: [String: String]?
    public var topicFilters: [MQTTTopicFilter]
    
    init(packetIdentifier: UInt16, topicFilters: [MQTTTopicFilter]) {
        self.packetIdentifier = packetIdentifier
        self.topicFilters = topicFilters
    }
    
    var mqttData: Data {
        /// 3.8.1 SUBSCRIBE Fixed Header
        /// Type+Flags to 1 byte
        var fixedHeader = Data()
        let type = MQTTType.SUBSCRIBE
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 1, bit0: 0)
        fixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        var remainingData = Data()
        
        /// 3.8.2 SUBSCRIBE Variable Header
        var variableHeaderData = Data()
        
        variableHeaderData += packetIdentifier.mqttData
        
        /// 3.8.2.1 SUBSCRIBE Properties
        var propertiesData = Data()
        /// 3.8.2.1.2 Subscription Identifier
        if let subscriptionIdentifier = self.subscriptionIdentifier {
            propertiesData += MQTTProperty<Int>(.subscriptionIdentifier, value: subscriptionIdentifier).mqttData
        }
        /// 3.8.2.1.3 User Property
        if let userProperty = self.userProperty {
            propertiesData += MQTTProperty<[String: String]>(.userProperty, value: userProperty).mqttData
        }
        
        /// 3.8.2.1.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        remainingData += variableHeaderData
        
        /// 3.8.3 SUBSCRIBE Payload
        var payloadData = Data()
        for topicFilter in self.topicFilters {
            payloadData += topicFilter.mqttData
        }
        
        remainingData += payloadData
        
        var completeData = Data()
        completeData.append(fixedHeader)
        completeData += remainingData.count.mqttData
        completeData.append(remainingData)
        return completeData
    }
    
}

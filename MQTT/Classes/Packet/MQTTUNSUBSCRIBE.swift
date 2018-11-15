//
//  MQTTUNSUBSCRIBE.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.10 UNSUBSCRIBE – Unsubscribe request
class MQTTUNSUBSCRIBE: MQTTProtocol {
    
    var packetIdentifier: UInt16
    var userProperty: [String: String]?
    var topicFilters: [MQTTTopicFilter]
    
    init(packetIdentifier: UInt16, topicFilters: [MQTTTopicFilter]) {
        self.packetIdentifier = packetIdentifier
        self.topicFilters = topicFilters
    }
    
    var mqttData: Data {
        /// 3.10.1 UNSUBSCRIBE Fixed Header
        /// Type+Flags to 1 byte
        var unsubscribeFixedHeader = Data()
        let type = MQTTType.UNSUBSCRIBE
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 1, bit0: 0)
        unsubscribeFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        var remainingData = Data()
        
        /// 3.10.2 UNSUBSCRIBE Variable Header
        var variableHeaderData = Data()
        
        variableHeaderData += packetIdentifier.mqttData
        
        /// 3.10.2.1 UNSUBSCRIBE Properties
        var propertiesData = Data()
        /// 3.10.2.1.2 User Property
        if let userProperty = self.userProperty {
            propertiesData += MQTTProperty<[String: String]>(.userProperty, value: userProperty).mqttData
        }
        
        /// 3.10.2.1.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        remainingData += variableHeaderData
        
        /// 3.10.3 UNSUBSCRIBE Payload
        var payloadData = Data()
        for topicFilter in self.topicFilters {
            payloadData += topicFilter.mqttData
        }
        remainingData += payloadData
        
        var dataComplete = Data()
        dataComplete.append(unsubscribeFixedHeader)
        dataComplete += remainingData.count.mqttData
        dataComplete.append(remainingData)
        return dataComplete
    }
    
}

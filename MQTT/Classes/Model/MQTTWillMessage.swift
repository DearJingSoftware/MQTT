//
//  MQTTWillMessage.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTWillMessage {
    var willProperties: [MQTTWillProperty]
    var willTopic: String
    var willPayload: Data
    var willQoS: MQTTQoS
    var willRetain: Bool
    var willDelayInterval: UInt32?
    var willPayloadFormatIndicator: PayloadFormatIndicator?
    var willMessageExpiryInterval: UInt32?
    var willContentType: String?
    var willResponseTopic: String?
    var willCorrelationData: Data?
    var willUserProperty: [String: String]?
    
    var mqttData: Data {
        var dataBody = Data()
        /// 3.1.3.2.2 Property Length
        if let willDelayInterval = self.willDelayInterval {
            dataBody += MQTTProperty<UInt32>(.willDelayInterval, value: willDelayInterval).mqttData
        }
        /// 3.1.3.2.3 Payload Format Indicator
        if let willPayloadFormatIndicator = self.willPayloadFormatIndicator {
            dataBody += MQTTProperty<UInt8>(.payloadFormatIndicator, value: willPayloadFormatIndicator.rawValue).mqttData
        }
        /// 3.1.3.2.4 Message Expiry Interval
        if let willMessageExpiryInterval = self.willMessageExpiryInterval {
            dataBody += MQTTProperty<UInt32>(.messageExpiryInterval, value: willMessageExpiryInterval).mqttData
        }
        /// 3.1.3.2.5 Content Type
        if let willContentType = self.willContentType {
            dataBody += MQTTProperty<String>(.contentType, value: willContentType).mqttData
        }
        /// 3.1.3.2.6 Response Topic
        if let willResponseTopic = self.willResponseTopic {
            dataBody += MQTTProperty<String>(.responseTopic, value: willResponseTopic).mqttData
        }
        /// 3.1.3.2.7 Correlation Data
        if let willCorrelationData = self.willCorrelationData {
            dataBody += willCorrelationData
        }
        /// 3.1.3.2.8 User Property
        if let willUserProperty = self.willUserProperty {
            dataBody += MQTTProperty<[String : String]>(.userProperty, value: willUserProperty).mqttData
        }
        var data = Data()
        /// 3.1.3.2.1 Property Length
        data += dataBody.count.mqttData
        data += dataBody
        return data
    }
}


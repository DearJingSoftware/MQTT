//
//  MQTTTopicFilter.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

class MQTTTopicFilter {
    var topic: String
    private var options: UInt8 = 0b0000_0000
    var maximumQoS: MQTTQoS
    var noLocal: Bool
    var retain: Bool
    var retainHandlingOption: MQTTRetainHandlingOption
    
    init(topic: String) {
        self.topic = topic
        self.maximumQoS = .qos2
        self.noLocal = false
        self.retain = false
        self.retainHandlingOption = .none
    }
    
    var mqttData: Data {
        var data = Data()
        data += topic.mqttData
        switch maximumQoS {
        case .qos0:
            options &= 0b1111_1100
        case .qos1:
            options &= 0b1111_1101
            options |= 0b0000_0001
        case .qos2:
            options |= 0b0000_0010
            options &= 0b1111_1110
        }
        if noLocal {
            options |= 0b0000_0100
        } else {
            options &= 0b1111_1011
        }
        if retain {
            options |= 0b0000_1000
        } else {
            options &= 0b1111_0111
        }
        switch retainHandlingOption {
        case .sendOnSubscribe:
            options &= 0b1100_1111
        case .sendOnlyWhenSubscribeIsNew:
            options &= 0b1101_1111
            options |= 0b0001_0000
        case .none:
            options |= 0b0010_0000
            options &= 0b1110_1111
        }
        data.append(options)
        return data
    }
}

enum MQTTRetainHandlingOption: UInt8 {
    case sendOnSubscribe = 0
    case sendOnlyWhenSubscribeIsNew = 1
    case none = 2
}

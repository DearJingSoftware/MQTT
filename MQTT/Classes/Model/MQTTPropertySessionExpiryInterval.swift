//
//  MQTTPropertySessionExpiryInterval.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTPropertySessionExpiryInterval {
    var identifier: MQTTPropertyType = .sessionExpiryInterval
    var interval: UInt32
    
    init(_ interval: UInt32) {
        self.interval = interval
    }
    
    var mqttData: Data {
        var data = Data()
        data += identifier.rawValue.mqttData
        data += interval.mqttData
        return data
    }
}

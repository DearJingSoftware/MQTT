//
//  MQTTPropertyMaximumPacketSize.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTPropertyMaximumPacketSize {
    var identifier: MQTTPropertyType = .maximumPacketSize
    var maximumPacketSize: UInt32
    
    init(_ maximumPacketSize: UInt32) {
        self.maximumPacketSize = maximumPacketSize
    }
    
    var mqttData: Data {
        var data = Data()
        data += identifier.rawValue.mqttData
        data += maximumPacketSize.mqttData
        return data
    }
}

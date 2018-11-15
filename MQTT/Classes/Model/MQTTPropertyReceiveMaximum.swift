//
//  MQTTPropertyReceiveMaximum.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTPropertyReceiveMaximum {
    var identifier: MQTTPropertyType = .receiveMaximum
    var receiveMaximum: UInt16
    
    init(_ receiveMaximum: UInt16) {
        self.receiveMaximum = receiveMaximum
    }
    
    var mqttData: Data {
        var data = Data()
        data += identifier.rawValue.mqttData
        data += receiveMaximum.mqttData
        return data
    }
}

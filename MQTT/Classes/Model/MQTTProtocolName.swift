//
//  MQTTProtocolName.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTProtocolName {
    var name = "MQTT"
    var mqttData: Data {
        get {
            return self.name.mqttData
        }
    }
}

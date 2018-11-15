//
//  MQTTProtocolVersion.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTProtocolVersion {
    var level: UInt8 = 5
    var mqttData: Data {
        get {
            var data = Data()
            data.append(level)
            return data
        }
    }
}

//
//  MQTTProperty.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTProperty<T: MQTTData> {
    var type: MQTTPropertyType
    var value: T
    
    init(_ type: MQTTPropertyType, value: T) {
        self.type = type
        self.value = value
    }
    
    var mqttData: Data {
        var data = Data()
        data += type.rawValue.mqttData
        data += value.mqttData
        return data
    }
}


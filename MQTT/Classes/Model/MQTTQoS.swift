//
//  MQTTQoS.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/7.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

enum MQTTQoS: UInt8 {
    case qos0 = 0
    case qos1 = 1
    case qos2 = 2
    /// A value of 3 (0x03) is a Malformed Packet.
}

//
//  MQTTPINGREQ.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.12 PINGREQ – PING request
class MQTTPINGREQ: MQTTProtocol {

    init() {

    }

    var mqttData: Data {
        /// 3.12.1 PINGREQ Fixed Header
        /// Type+Flags to 1 byte
        var data = Data()
        let type = MQTTType.PINGREQ
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        data.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        let remainLength: UInt8 = 0
        data.append(remainLength)
        return data
    }

}

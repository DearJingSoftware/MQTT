//
//  MQTTSUBACK.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

class MQTTSUBACK: MQTTProtocol {
    
    var packetIdentifier: UInt16
    var reasonString: String?
    var userProperties: [String: String]?
    var reasonCodes: [MQTTSUBACKReasonCode] = []
    
    init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
    }
    
    var mqttData: Data {
        return Data()
    }
}

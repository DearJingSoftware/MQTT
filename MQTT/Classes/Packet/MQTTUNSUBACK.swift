//
//  MQTTUNSUBACK.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

public class MQTTUNSUBACK: MQTTProtocol {
    
    public var packetIdentifier: UInt16
    public var reasonString: String?
    public var userProperties: [String: String]?
    public var reasonCodes: [MQTTUNSUBACKReasonCode] = []
    
    init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
    }
    
    var mqttData: Data {
        return Data()
    }
}

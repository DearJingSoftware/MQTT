//
//  MQTTCONNACK.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/9.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

public class MQTTCONNACK: MQTTProtocol {
    
    var sessionPresent: Bool?
    var reasonCode: MQTTCONNACKReasonCode
    var sessionExpiryInterval: UInt32?
    var receiveMaximum: UInt16?
    var maximumQoS: MQTTCONNACKMaximumQoS?
    var retain: Bool?
    var maximumPacketSize: UInt32?
    var assignedClientIdentifier: String?
    var topicAliasMaximum: UInt16?
    var reasonString: String?
    var userProperties: [String: String]?
    var wildcardSubscriptionAvailable: Bool?
    var subscriptionIdentifiersAvailable: Bool?
    var sharedSubscriptionAvailable: Bool?
    var serverKeepAlive: UInt16?
    var responseInformation: String?
    var serverReference: String?
    var authenticationMethod: String?
    var authenticationData: Data?
    
    init(reasonCode: MQTTCONNACKReasonCode) {
        self.reasonCode = reasonCode
    }
    

    
    
    var mqttData: Data {
        /// Client never sends CONNACK
        return Data()
    }
    
}

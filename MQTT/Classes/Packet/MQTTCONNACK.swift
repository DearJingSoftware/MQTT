//
//  MQTTCONNACK.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/9.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

public class MQTTCONNACK: MQTTProtocol {
    
    public var sessionPresent: Bool?
    public var reasonCode: MQTTCONNACKReasonCode
    public var sessionExpiryInterval: UInt32?
    public var receiveMaximum: UInt16?
    public var maximumQoS: MQTTCONNACKMaximumQoS?
    public var retain: Bool?
    public var maximumPacketSize: UInt32?
    public var assignedClientIdentifier: String?
    public var topicAliasMaximum: UInt16?
    public var reasonString: String?
    public var userProperties: [String: String]?
    public var wildcardSubscriptionAvailable: Bool?
    public var subscriptionIdentifiersAvailable: Bool?
    public var sharedSubscriptionAvailable: Bool?
    public var serverKeepAlive: UInt16?
    public var responseInformation: String?
    public var serverReference: String?
    public var authenticationMethod: String?
    public var authenticationData: Data?
    
    init(reasonCode: MQTTCONNACKReasonCode) {
        self.reasonCode = reasonCode
    }
    
    var mqttData: Data {
        /// Client never sends CONNACK
        return Data()
    }
    
}

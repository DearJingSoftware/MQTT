//
//  MQTTPropertyType.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

public enum MQTTPropertyType: UInt32 {
    case payloadFormatIndicator = 0x01
    case messageExpiryInterval = 0x02
    case contentType = 0x03
    case responseTopic = 0x08
    case correlationData = 0x09
    case subscriptionIdentifier = 0x0B
    case sessionExpiryInterval = 0x11
    case assignedClientIdentifier = 0x12
    case serverKeepAlive = 0x13
    case authenticationMethod = 0x15
    case authenticationData = 0x16
    case requestProblemInfomation = 0x17
    case willDelayInterval = 0x18
    case requestResponseInformation = 0x19
    case responseInformation = 0x1A
    case serverReference = 0x1C
    case reasonString = 0x1F
    case receiveMaximum = 0x21
    case topicAliasMaximum = 0x22
    case topicAlias = 0x23
    case maximumQoS = 0x24
    case retainAvailable = 0x25
    case userProperty = 0x26
    case maximumPacketSize = 0x27
    case wildcardSubscriptionAvailable = 0x28
    case subscriptionIdentifiersAvailable = 0x29
    case sharedSubscriptionAvailable = 0x2A
}

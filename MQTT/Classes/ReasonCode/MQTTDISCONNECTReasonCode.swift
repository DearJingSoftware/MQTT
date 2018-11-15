//
//  MQTTDISCONNECTReasonCode.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

enum MQTTDISCONNECTReasonCode: UInt8 {
    case normalDisconnection = 0x00
    case disconnectWithWillMessage = 0x4
    case unspecifiedError = 0x80
    case malformedPacket = 0x81
    case protocolError = 0x82
    case implementationSpecificError = 0x83
    case notAuthorized = 0x87
    case serverBusy = 0x89
    case serverShuttingDown = 0x8B
    case keepAliveTimeout = 0x8D
    case sessionTakenOver = 0x8E
    case topicFilterInvalid = 0x8F
    case topicNameInvalid = 0x90
    case receiveMaximumExceeded = 0x93
    case topicAliasInvalid = 0x94
    case packetTooLarge = 0x95
    case messageRateTooHigh = 0x96
    case quotaExceeded = 0x97
    case administrativeAction = 0x98
    case payloadFormatInvalid = 0x99
    case retainNotSupported = 0x9A
    case qosNotSupported = 0x9B
    case useAnotherServer = 0x9C
    case serverMoved = 0x9D
    case sharedSubscriptionsNotSupported = 0x9E
    case connectionRateExceeded = 0x9F
    case maximumConnectTime = 0xA0
    case subscriptionIdentifiersNotSupported = 0xA1
    case wildcardSubscriptionsNotSupported = 0xA2
}

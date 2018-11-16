//
//  MQTTSUBACKReasonCode.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

public enum MQTTSUBACKReasonCode: UInt8 {
    case grantedQoS0 = 0x00
    case grantedQoS1 = 0x01
    case grantedQoS2 = 0x02
    case unspecifiedError = 0x80
    case implementationSpecificError = 0x83
    case notAuthorized = 0x87
    case topicFilterInvalid = 0x8F
    case packetIdentifierInUse = 0x91
    case quotaExceeded = 0x97
    case sharedSubscriptionsNotSupported = 0x9E
    case subscriptionIdentifiersNotSupported = 0xA1
    case wildcardSubscriptionsNotSupported = 0xA2
}

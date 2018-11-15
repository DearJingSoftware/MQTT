//
//  MQTTUNSUBACKReasonCode.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/15.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

enum MQTTUNSUBACKReasonCode: UInt8 {
    case grantedQoS0 = 0x00
    case noSubscriptionExisted = 0x11
    case unspecifiedError = 0x80
    case implementationSpecificError = 0x83
    case notAuthorized = 0x87
    case topicFilterInvalid = 0x8F
    case packetIdentifierInUse = 0x91
}

//
//  MQTTPUBRECReasonCode.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

enum MQTTPUBRECReasonCode: UInt8 {
    case success = 0x00
    case noMatchingSubscribers = 0x10
    case unspecifiedError = 0x80
    case implementationSpecificError = 0x83
    case notAuthorized = 0x87
    case topicNameInvalid = 0x90
    case packetIdentifierInUse = 0x91
    case quotaExceeded = 0x97
    case payloadFormatInvalid = 0x99
}

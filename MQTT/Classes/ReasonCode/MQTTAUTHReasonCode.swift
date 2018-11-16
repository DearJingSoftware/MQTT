//
//  MQTTAUTHReasonCode.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

public enum MQTTAUTHReasonCode: UInt8 {
    case success = 0x00
    case continueAuthentication = 0x18
    case ReAuthenticate = 0x19
}

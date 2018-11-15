//
//  MQTTPUBACK.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

class MQTTPUBACK: MQTTProtocol {
    
    var packetIdentifier: UInt16
    var reasonCode: MQTTPUBACKReasonCode
    var reasonString: String?
    var userProperties: [String: String]?
    
    init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
        self.reasonCode = .success
    }
    
    init(packetIdentifier: UInt16, reasonCode: MQTTPUBACKReasonCode) {
        self.packetIdentifier = packetIdentifier
        self.reasonCode = reasonCode
    }
    
    var mqttData: Data {
        /// 3.4 PUBACK – Publish acknowledgement
        /// Type+Flags to 1 byte
        var pubackFixedHeader = Data()
        let type = MQTTType.PUBACK
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        pubackFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        /// 3.4.2 PUBACK Variable Header
        var variableHeaderData = Data()
        /// Packet Identifier from the PUBLISH packet that is being acknowledged
        variableHeaderData += packetIdentifier.mqttData
        /// 3.4.2.1 PUBACK Reason Code
        variableHeaderData += reasonCode.rawValue.mqttData
        /// 3.4.2.2 PUBACK Properties
        var propertiesData = Data()
        /// 3.4.2.2.2 Reason String
        if let reasonString = self.reasonString {
            propertiesData += MQTTProperty<String>(.reasonString, value: reasonString).mqttData
        }
        /// 3.4.2.2.3 User Property
        if let userProperty = self.userProperties {
            propertiesData += MQTTProperty<[String : String]>(.userProperty, value: userProperty).mqttData
        }
        
        /// 3.4.2.2.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        
        var completeData = Data()
        completeData.append(pubackFixedHeader)
        completeData += variableHeaderData.count.mqttData
        completeData.append(variableHeaderData)
        return completeData
    }
}

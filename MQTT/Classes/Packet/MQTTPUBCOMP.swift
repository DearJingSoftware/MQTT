//
//  MQTTPUBCOMP.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.7 PUBCOMP – Publish complete (QoS 2 delivery part 3)
class MQTTPUBCOMP: MQTTProtocol {
    
    var packetIdentifier: UInt16
    var reasonCode: MQTTPUBCOMPReasonCode
    var reasonString: String?
    var userProperties: [String: String]?
    
    init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
        self.reasonCode = .success
    }
    
    init(packetIdentifier: UInt16, reasonCode: MQTTPUBCOMPReasonCode) {
        self.packetIdentifier = packetIdentifier
        self.reasonCode = reasonCode
    }
    
    var mqttData: Data {
        /// 3.7.1 PUBCOMP Fixed Header
        /// Type+Flags to 1 byte
        var pubackFixedHeader = Data()
        let type = MQTTType.PUBCOMP
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        pubackFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        /// 3.7.2 PUBCOMP Variable Header
        var variableHeaderData = Data()
        /// Packet Identifier from the PUBLISH packet that is being acknowledged
        variableHeaderData += packetIdentifier.mqttData
        /// 3.7.2.1 PUBCOMP Reason Code
        variableHeaderData += reasonCode.rawValue.mqttData
        /// 3.7.2.2 PUBCOMP Properties
        var propertiesData = Data()
        /// 3.7.2.2.2 Reason String
        if let reasonString = self.reasonString {
            propertiesData += MQTTProperty<String>(.reasonString, value: reasonString).mqttData
        }
        /// 3.7.2.2.3 User Property
        if let userProperty = self.userProperties {
            propertiesData += MQTTProperty<[String : String]>(.userProperty, value: userProperty).mqttData
        }
        
        /// 3.7.2.2.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        
        var completeData = Data()
        completeData.append(pubackFixedHeader)
        completeData += variableHeaderData.count.mqttData
        completeData.append(variableHeaderData)
        return completeData
    }
}

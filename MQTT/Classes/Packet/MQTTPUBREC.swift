//
//  MQTTPUBREC.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.5 PUBREC – Publish received (QoS 2 delivery part 1)
public class MQTTPUBREC: MQTTProtocol {
    
    public var packetIdentifier: UInt16
    public var reasonCode: MQTTPUBRECReasonCode
    public var reasonString: String?
    public var userProperties: [String: String]?
    
    init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
        self.reasonCode = .success
    }
    
    init(packetIdentifier: UInt16, reasonCode: MQTTPUBRECReasonCode) {
        self.packetIdentifier = packetIdentifier
        self.reasonCode = reasonCode
    }
    
    var mqttData: Data {
        /// 3.5.1 PUBREC Fixed Header
        /// Type+Flags to 1 byte
        var pubackFixedHeader = Data()
        let type = MQTTType.PUBREC
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        pubackFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        /// 3.5.2 PUBREC Variable Header
        var variableHeaderData = Data()
        /// Packet Identifier from the PUBLISH packet that is being acknowledged
        variableHeaderData += packetIdentifier.mqttData
        /// 3.5.2.1 PUBREC Reason Code
        variableHeaderData += reasonCode.rawValue.mqttData
        /// 3.5.2.2 PUBREC Properties
        var propertiesData = Data()
        /// 3.5.2.2.2 Reason String
        if let reasonString = self.reasonString {
            propertiesData += MQTTProperty<String>(.reasonString, value: reasonString).mqttData
        }
        /// 3.5.2.2.3 User Property
        if let userProperty = self.userProperties {
            propertiesData += MQTTProperty<[String : String]>(.userProperty, value: userProperty).mqttData
        }
        
        /// 3.5.2.2.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        
        var completeData = Data()
        completeData.append(pubackFixedHeader)
        completeData += variableHeaderData.count.mqttData
        completeData.append(variableHeaderData)
        return completeData
    }
}

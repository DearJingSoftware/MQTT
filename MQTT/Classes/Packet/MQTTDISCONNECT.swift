//
//  MQTTDISCONNECT.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.14 DISCONNECT – Disconnect notification
public class MQTTDISCONNECT: MQTTProtocol {
    
    public var reasonCode: MQTTDISCONNECTReasonCode
    public var sessionExpiryInterval: UInt32?
    public var reasonString: String?
    public var userProperties: [String: String]?
    public var serverReference: String?
    
    init(reasonCode: MQTTDISCONNECTReasonCode) {
        self.reasonCode = reasonCode
    }
    
    var mqttData: Data {
        /// 3.14.1 DISCONNECT Fixed Header
        /// Type+Flags to 1 byte
        var subscribeFixedHeader = Data()
        let type = MQTTType.DISCONNECT
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        subscribeFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        var remainingData = Data()
        
        /// 3.14.2 DISCONNECT Variable Header
        var variableHeaderData = Data()
        /// 3.14.2.1 Disconnect Reason Code
        variableHeaderData += reasonCode.rawValue.mqttData
        
        /// 3.14.2.2 DISCONNECT Properties
        var propertiesData = Data()
        /// 3.14.2.2.2 Session Expiry Interval
        if let sessionExpiryInterval = self.sessionExpiryInterval {
            propertiesData += MQTTProperty<UInt32>(.sessionExpiryInterval, value: sessionExpiryInterval).mqttData
        }
        /// 3.14.2.2.3 Reason String
        if let reasonString = self.reasonString {
            propertiesData += MQTTProperty<String>(.reasonString, value: reasonString).mqttData
        }
        /// 3.14.2.2.4 User Property
        if let userProperty = self.userProperties {
            propertiesData += MQTTProperty<[String : String]>(.userProperty, value: userProperty).mqttData
        }
        /// 3.4.2.2.5 Server Reference
        if let serverReference = self.serverReference {
            propertiesData += MQTTProperty<String>(.serverReference, value: serverReference).mqttData
        }
        
        /// 3.14.2.2.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        remainingData += variableHeaderData
        
        var completeData = Data()
        completeData.append(subscribeFixedHeader)
        completeData += remainingData.count.mqttData
        completeData.append(remainingData)
        return completeData
    }
    
}

//
//  MQTTAUTH.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/8.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
/// 3.15 AUTH – Authentication exchange
public class MQTTAUTH: MQTTProtocol {
    
    var reasonCode: MQTTAUTHReasonCode
    var authenticationMethod: String?
    var authenticationData: Data?
    var reasonString: String?
    var userProperties: [String: String]?
    
    init(reasonCode: MQTTAUTHReasonCode) {
        self.reasonCode = reasonCode
    }
    
    var mqttData: Data {
        /// 3.15.1 AUTH Fixed Header
        /// Type+Flags to 1 byte
        var connectFixedHeader = Data()
        let type = MQTTType.CONNECT
        // Reserved
        let flags = MQTTFlags(bit3: 0, bit2: 0, bit1: 0, bit0: 0)
        connectFixedHeader.append((UInt8(type.rawValue<<4 + flags.toUInt8())))
        
        
        
        var remainingData = Data()
        
        /// 3.15.2 AUTH Variable Header
        var variableHeaderData = Data()
        /// 3.15.2.1 Authenticate Reason Code
        variableHeaderData += reasonCode.rawValue.mqttData
        
        /// 3.15.2.2 AUTH Properties
        var propertiesData = Data()
        /// 3.15.2.2.2 Authentication Method
        if let authenticationMethod = self.authenticationMethod {
            propertiesData += MQTTProperty<String>(.authenticationMethod, value: authenticationMethod).mqttData
        }
        /// 3.15.2.2.3 Authentication Data
        if let authenticationData = self.authenticationData {
            propertiesData += authenticationData
        }
        /// 3.15.2.2.4 Reason String
        if let reasonString = self.reasonString {
            propertiesData += MQTTProperty<String>(.reasonString, value: reasonString).mqttData
        }
        /// 3.15.2.2.5 User Property
        if let userProperty = self.userProperties {
            propertiesData += MQTTProperty<[String : String]>(.userProperty, value: userProperty).mqttData
        }
        
        /// 3.15.2.2.1 Property Length
        variableHeaderData += propertiesData.count.mqttData
        variableHeaderData += propertiesData
        remainingData += variableHeaderData
        
        var completeData = Data()
        completeData.append(connectFixedHeader)
        completeData += remainingData.count.mqttData
        completeData.append(remainingData)
        return completeData
    }
    
}

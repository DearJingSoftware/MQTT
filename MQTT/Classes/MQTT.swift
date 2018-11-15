//
//  MQTT.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/5.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation
import Network

public protocol MQTTDelegate {
    func didSendCONNECT()
    func didReceiveCONNACK(packet: MQTTCONNACK, username: String?)
    func didSendPING()
    func didReceivePINGRESP()
    func didReceivePUBACK()
    func didReceivePUBREC()
    func didReceivePUBREL()
    func didReceivePUBCOMP()
    func didReceivePUBLISH(packet: MQTTPUBLISH)
    func didReceiveSUBACK()
    func didReceiveUNSUBACK()
    func didReceiveDISCONNECT()
    func waitPINGRESPTimedOut()
}

public enum MQTTStatus {
    case connected
    case disconnected
}

@available(iOS 12.0, *)
public class MQTT {
    
    public var host: String
    public var port: UInt16
    public var clientID: String
    public var username: String?
    public var password: String?
    public var ssl: Bool = true
    public var cleanSession = true
    public var pingInterval = 5.0
    var pingTimer: Timer?
    var isPINGRESPReceived = true
    public var status: MQTTStatus = .disconnected
    var _packetID: UInt16 = 1117
    var packetID: UInt16 {
        get {
            if self._packetID < 0xFFFF {
                self._packetID += 1
            } else {
                self._packetID = 0
            }
            return self._packetID
        }
    }
    
    var connection: NWConnection
    var myQueue: DispatchQueue
    var listener: NWListener?
    public var autoReconnect = true
    
    var type: MQTTType = .Reserved
    var remainingLength: UInt32 = 0
    var isTail = false
    var fixedHeaderData = Data()
    
    public var delegate: MQTTDelegate?
    
    public init(clientID: String, host: String, port: UInt16, username: String?, password: String?) {
        self.clientID = clientID
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        
        myQueue = DispatchQueue(label: "myQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        
        connection = NWConnection(host: NWEndpoint.Host(self.host), port: NWEndpoint.Port(rawValue: self.port)!, using: .tcp)
        do {
            listener = try NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)
        } catch {
            print("error")
        }
        
    }
    
    public func start() {
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("ready")
            case .waiting(let error):
                print(error.localizedDescription)
            case .failed(let error):
                print(error.localizedDescription)
            case .cancelled:
                print("cancelled")
            case .preparing:
                print("preparing")
            case .setup:
                print("setup")
            }
        }
        connection.start(queue: myQueue)
        let packet = MQTTCONNECT(clientID: self.clientID)
        packet.username = self.username
        packet.password = self.password
        packet.cleanStart = true
        self.sendPacket(self.connection, packet: packet)
        self.receive()
    }
    
    public func reconnect() {
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("ready")
            case .waiting(let error):
                print(error.localizedDescription)
            case .failed(let error):
                print(error.localizedDescription)
            case .cancelled:
                print("cancelled")
            case .preparing:
                print("preparing")
            case .setup:
                print("setup")
            }
        }
        connection.restart()
        let packet = MQTTCONNECT(clientID: self.clientID)
        packet.username = self.username
        packet.password = self.password
        packet.cleanStart = true
        self.sendPacket(self.connection, packet: packet)
        self.receive()
    }
    
    func sendPacket(_ connection: NWConnection, packet: MQTTProtocol) {
        connection.send(content: packet.mqttData, completion: .contentProcessed({ sendError in
            if sendError != nil {
                // Handle error in sending
                print("error")
            } else {
                // Send has been processed
            }
        }))
    }
    
    func receiveRemainingDataRecursively() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { (data, contentContext, isComplete, error) in
            if let data = data {
                self.fixedHeaderData += data
                self.remainingLength = self.remainingLength << 7
                self.remainingLength += UInt32(data.first! & 0b0111_1111)
                if (data.first! & 0b1000_0000) == 1 {
                    /// Not tail
                    self.receiveRemainingDataRecursively()
                } else {
                    /// Tail
                    /// Receive remaining data
                    if self.remainingLength == 0 {
                        switch self.type {
                        case .PINGRESP:
                            self.isPINGRESPReceived = true
                            self.delegate?.didReceivePINGRESP()
                        default:
                            break
                        }
                    } else {
                        self.connection.receive(minimumIncompleteLength: Int(self.remainingLength), maximumLength: Int(self.remainingLength), completion: { (data, contentContext, isComplete, error) in
                            if let data = data {
                                var completeData = Data()
                                completeData += self.fixedHeaderData
                                completeData += data
                                let decoder = MQTTDecoder()
                                switch self.type {
                                case .CONNACK:
                                    if let packet = decoder.decodeCONNACK(remainingData: data) {
                                        self.delegate?.didReceiveCONNACK(packet: packet, username: self.username)
                                        self.sendPING()
                                    } else {
                                        /// Malformed packet
                                    }
                                case .PUBLISH:
                                    print("PUBLISH")
                                    if let packet = decoder.decodePUBLISH(fixedHeaderData: self.fixedHeaderData, remainingData: data) {
                                        self.delegate?.didReceivePUBLISH(packet: packet)
                                        switch packet.qos {
                                        case .qos0:
                                            break
                                        case .qos1:
                                            let puback = MQTTPUBACK(packetIdentifier: packet.packetIdentifier!, reasonCode: .success)
                                            self.sendPacket(self.connection, packet: puback)
                                        case .qos2:
                                            let pubrec = MQTTPUBREC(packetIdentifier: packet.packetIdentifier!, reasonCode: .success)
                                            self.sendPacket(self.connection, packet: pubrec)
                                        }
                                    } else {
                                        /// Malformed packet
                                    }
                                case .PUBREC:
                                    print("PUBREC")
                                case .SUBACK:
                                    self.delegate?.didReceiveSUBACK()
                                default:
                                    break
                                }
                                
                            }
                        })
                    }
                    self.receive()
                }
            }
        }
    }
    
    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { (data, contentContext, isComplete, error) in
            if let data = data {
                self.remainingLength = 0
                if let type = MQTTType(rawValue: data.first! >> 4) {
                    self.type = type
                    self.fixedHeaderData = Data()
                    self.fixedHeaderData += data
                    self.receiveRemainingDataRecursively()
                } else {
                    /// Malformed Packet
                    return
                }
            }
        }
    }
    
    func sendPING() {
        DispatchQueue.global(qos: .background).async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: self.pingInterval, repeats: true, block: { timer in
                if self.isPINGRESPReceived {
                    self.delegate?.didSendPING()
                    let packet = MQTTPINGREQ()
                    self.sendPacket(self.connection, packet: packet)
                    self.isPINGRESPReceived = false
                } else {
                    self.delegate?.waitPINGRESPTimedOut()
                    if self.autoReconnect {
                        self.reconnect()
                    }
                }
            })
            let runLoop = RunLoop.current
            runLoop.add(self.pingTimer!, forMode: RunLoop.Mode.default)
            runLoop.run()
        }
    }
    
    deinit {
        self.pingTimer?.invalidate()
    }
    
    public func subscribe(topic: String, qos: MQTTQoS) {
        let filter = MQTTTopicFilter(topic: topic)
        let packet = MQTTSUBSCRIBE(packetIdentifier: 123, topicFilters: [filter])
        sendPacket(self.connection, packet: packet)
    }
    
    public func publish(topic: String, message: String, qos: MQTTQoS, retain: Bool? = false, dup: Bool? = false) -> UInt16 {
        let packet = MQTTPUBLISH(topic: topic)
        packet.applicationMessage = message.data(using: .utf8)
        packet.qos = qos
        packet.retain = retain!
        packet.dup = dup!
        packet.packetIdentifier = packetID
        sendPacket(self.connection, packet: packet)
        return packet.packetIdentifier!
    }
    
    public func stop() {
        
    }
    
}



//
//  Flags.swift
//  xiaodaoxueyuan
//
//  Created by ailion on 2018/11/5.
//  Copyright © 2018 ailion. All rights reserved.
//

import Foundation

struct MQTTFlags {
    var _bit3: Int
    var bit3: Int {
        get {
            return self._bit3
        }
        set {
            if newValue == 0 || newValue == 1 {
                self._bit3 = newValue
            } else {
                return
            }
        }
    }
    var _bit2: Int
    var bit2: Int {
        get {
            return self._bit2
        }
        set {
            if newValue == 0 || newValue == 1 {
                self._bit2 = newValue
            } else {
                return
            }
        }
    }
    var _bit1: Int
    var bit1: Int {
        get {
            return self._bit1
        }
        set {
            if newValue == 0 || newValue == 1 {
                self._bit1 = newValue
            } else {
                return
            }
        }
    }
    var _bit0: Int
    var bit0: Int {
        get {
            return self._bit0
        }
        set {
            if newValue == 0 || newValue == 1 {
                self._bit0 = newValue
            } else {
                return
            }
        }
    }
    
    init(bit3: Int, bit2: Int, bit1: Int, bit0: Int) {
        _bit3 = bit3
        _bit2 = bit2
        _bit1 = bit1
        _bit0 = bit0
    }
    
    func toUInt8() -> UInt8 {
        return UInt8(_bit3 << 3) + UInt8(_bit2) << 2 + UInt8(_bit1 << 1) + UInt8(_bit0)
    }
    
//    func toUInt8() -> UInt8 {
//        let value3 = _bit3 << 3
//        let value2 = _bit2 << 2
//        let value1 = _bit1 << 1
//        let value0 = _bit0
//        return value3 + value2 + value1 + value0
//    }
}

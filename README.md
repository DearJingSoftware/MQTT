# MQTT

[![CI Status](https://img.shields.io/travis/andy1247008998/MQTT.svg?style=flat)](https://travis-ci.org/andy1247008998/MQTT)
[![Version](https://img.shields.io/cocoapods/v/MQTT.svg?style=flat)](https://cocoapods.org/pods/MQTT)
[![License](https://img.shields.io/cocoapods/l/MQTT.svg?style=flat)](https://cocoapods.org/pods/MQTT)
[![Platform](https://img.shields.io/cocoapods/p/MQTT.svg?style=flat)](https://cocoapods.org/pods/MQTT)

## Introduction
This is a MQTT v5.0 client for Swift based on Apple's Network.framework.

MQTT Version 5.0:  http://docs.oasis-open.org/mqtt/mqtt/v5.0/cs02/mqtt-v5.0-cs02.html

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

This project is still under development. DO NOT use it in production!

PRs are warmly welcomed!

## Requirements

iOS 12.0+ / macOS 10.14+

Swift 4.2

Broker with MQTT v5.0 support


## Installation

MQTT is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MQTT'
```

## Usage

```swift
/// In your AppDelegate or UIViewController
import MQTT
mqtt = MQTT(clientID: clientID, host: "mqtt.mustu.cn", port: 1883, username: username, password: password)
mqtt.delegate = self
mqtt.cleanSession = false
mqtt.start()

/// You MUST stop MQTT service when app did enter background, otherwise NWConnection will fail and NSTimer won't stop!
func applicationDidEnterBackground(_ application: UIApplication) {
mqtt.stop()
}

/// MQTT will start a new connection between client and broker.
func applicationWillEnterForeground(_ application: UIApplication) {
mqtt.start()
}
```

## Author
andy1247008998

## License

MQTT is available under the MIT license. See the LICENSE file for more info.

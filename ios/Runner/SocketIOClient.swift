//
//  SocketIOClient.swift
//  Runner
//
//  Created by Gokhan Alp on 16.04.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOClient {
    static let shared = SocketIOClient()
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    
    init() {
        self.manager.defaultSocket.on(clientEvent: .connect) { (data, ack) in
            if let flutterchannel = (UIApplication.shared.delegate as? AppDelegate)?.flutterchannel {
                flutterchannel.invokeMethod("connected", arguments: nil)
            }
        }
        
        self.manager.defaultSocket.on(clientEvent: .disconnect) { (data, ack) in
            if let flutterchannel = (UIApplication.shared.delegate as? AppDelegate)?.flutterchannel {
                flutterchannel.invokeMethod("disconnected", arguments: nil)
            }
        }
        
        self.manager.defaultSocket.on("message") { (data, ack) in
            if data.count > 1, let sender = data[0] as? String, let message = data[1] as? String {
                if let flutterchannel = (UIApplication.shared.delegate as? AppDelegate)?.flutterchannel {
                    flutterchannel.invokeMethod("messageReceived", arguments:  [sender, message])
                }
            }
        }
    }
    
    static func flutterChannelTest(arg: String) -> Bool {
        print("IOS flutterChannelTest arg: \(arg)")
        return arg == "test" ? true : false
    }
    
    func connect() {
        self.manager.defaultSocket.connect()
    }
    
    func disconnect() {
        self.manager.defaultSocket.disconnect()
    }
    
    func sendMessage(sender: String, message: String) {
        self.manager.defaultSocket.emit("sendMessage", sender, message) {
            print("SocketIO \(sender) tarafından şu mesaj gönderildi: \(message)")
        }
    }
    
}


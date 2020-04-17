import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let socketIOClient = SocketIOClient.shared
    var flutterchannel: FlutterMethodChannel?
     
     override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         if let controller = self.window.rootViewController as? FlutterViewController {
              
              self.flutterchannel = FlutterMethodChannel(name: "SocketIOClient", binaryMessenger: controller.binaryMessenger)
              
              self.flutterchannel?.setMethodCallHandler { (call, result) in
                 if call.method == "flutterChannelTest", let args = call.arguments as? [String: Any] {
                     if let arg = args["arg"] as? String {
                         let resultChannel = SocketIOClient.flutterChannelTest(arg: arg)
                         result(resultChannel)
                     }
                 } else if call.method == "connect" {
                      SocketIOClient.shared.connect()
                 } else if call.method == "disconnect" {
                      SocketIOClient.shared.disconnect()
                 } else if call.method == "sendMessage", let args = call.arguments as? [String: Any], let sender = args["sender"] as? String, let message = args["message"] as? String {
                    SocketIOClient.shared.sendMessage(sender: sender, message: message)
                 }
              }
         }
         
         GeneratedPluginRegistrant.register(with: self)
         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
}

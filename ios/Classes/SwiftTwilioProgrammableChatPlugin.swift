import Flutter
import UIKit

public class SwiftTwilioProgrammableChatPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "twilio_programmable_chat", binaryMessenger: registrar.messenger())
    let instance = SwiftTwilioProgrammableChatPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}

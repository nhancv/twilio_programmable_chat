import Flutter
import Foundation
import TwilioChatClient

public class ChatClientMethods {
    public static func updateToken(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let token = arguments["token"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.updateToken(token, completion: {(result: TCHResult) -> Void in
            if result.isSuccessful() {
                SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.updateToken => onSuccess")
                flutterResult(nil)
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.updateToken => onError: \(error)")
                    flutterResult(FlutterError(code: "\(error.code)", message: "\(error.description)", details: nil))
                }
            }
            } as TCHCompletion)
    }

    public static func shutdown(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.shutdown()
        result(nil)
    }

//    public static func registerForNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let arguments = call.arguments as? [String: Any?] else {
//            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
//        }
//
//        guard let platform = arguments["platform"] as? String else {
//            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'platform' parameter", details: nil))
//        }
//
//        if platform != "APNS" {
//            return result(FlutterError(code: "ERROR", message: "Only supported 'platform' on iOS is APNS", details: nil))
//        }
//
//         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, error: Error?) in
//                        SwiftTwilioProgrammableChatPlugin.debug("User responded to permissions request: \(granted)")
//                        if granted {
//                            SwiftTwilioProgrammableChatPlugin.debug("Requisite permissions have been granted")
//            //                self.methodChannel?.invokeMethod("permissions_granted", arguments: nil)
//                            DispatchQueue.main.async {
//                                let isRegistered = UIApplication.shared.isRegisteredForRemoteNotifications
//                                UIApplication.shared.registerForRemoteNotifications()
//                            }
//                            result(nil)
//                        }
//                    }
//        let flutterResult = result
//        if let token = SwiftTwilioProgrammableChatPlugin.apnsToken {
//            SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.register(withNotificationToken: token, completion: { (result: TCHResult) in
//                if result.isSuccessful() {
//                    SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.registerForNotification => onSuccess")
//                    flutterResult(nil)
//                } else {
//                    SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.registerForNotification => onError: \(String(describing: result.error))")
//                    flutterResult(FlutterError(code: "ERROR", message: "Failed to register for notifications with APNS", details: nil))
//                }
//            })
//        } else {
//            SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.registerForNotification => onError: APNS token has not been retrieved")
//            flutterResult(FlutterError(code: "ERROR", message: "Failed to register for notifications with APNS", details: nil))
//        }
//    }

//    public static func unregisterForNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let arguments = call.arguments as? [String: Any?] else {
//            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
//        }
//
//        guard let platform = arguments["platform"] as? String else {
//            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'platform' parameter", details: nil))
//        }
//
//        if platform != "APNS" {
//            return result(FlutterError(code: "ERROR", message: "Only supported 'platform' on iOS is APNS", details: nil))
//        }
//
//        let flutterResult = result
//        if let token = SwiftTwilioProgrammableChatPlugin.apnsToken {
//            SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.deregister(withNotificationToken: token, completion: { (result: TCHResult) in
//                if result.isSuccessful() {
//                    SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.unregisterForNotification => onSuccess")
//                    flutterResult(nil)
//                } else {
//                    SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.unregisterForNotification => onError: \(String(describing: result.error))")
//                    flutterResult(FlutterError(code: "ERROR", message: "Failed to deregister for notifications with APNS", details: nil))
//                }
//            })
//        } else {
//            SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.unregisterForNotification => onError: APNS token has not been retrieved")
//            flutterResult(FlutterError(code: "ERROR", message: "Failed to deregister for notifications with APNS", details: nil))
//        }
//    }
}

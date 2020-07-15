import Flutter
import Foundation
import TwilioChatClient

public class UsersMethods {
    public static func getChannelUserDescriptors(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channelRes = channel as TCHChannel? {
                SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.users()?.userDescriptors(for: channelRes, completion: { (result: TCHResult, userDescriptors: TCHUserDescriptorPaginator?) in
                    if result.isSuccessful(), let descriptors = userDescriptors as TCHUserDescriptorPaginator? {
                        SwiftTwilioProgrammableChatPlugin.debug("UsersMethods.getChannelUserDescriptors => onSuccess")
                        let pageId = PaginatorManager.setPaginator(descriptors)
                        flutterResult(Mapper.userDescriptorsToDict(pageId, descriptors))
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("UsersMethods.getChannelUserDescriptors => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving user descriptors for channel: \(channelSid)", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("UsersMethods.getChannelUserDescriptors => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel: \(channelSid)", details: nil))
            }
        })
    }

    public static func getUserDescriptor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.users()?.userDescriptor(withIdentity: identity, completion: { (result: TCHResult, user: TCHUserDescriptor?) in
            if result.isSuccessful() {
                if let userDesc = user as TCHUserDescriptor? {
                    SwiftTwilioProgrammableChatPlugin.debug("UsersMethods.getUserDescriptor => onSuccess")
                    flutterResult(Mapper.userDescriptorToDict(userDesc))
                } else {
                    flutterResult(FlutterError(code: "ERROR", message: "Could not resolve userDescriptor for identity: \(identity)", details: nil))
                }
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("UsersMethods.getUserDescriptor => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving userDescriptor for identity: \(identity)", details: nil))
            }
        })
    }

    public static func getAndSubscribeUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.users()?.userDescriptor(withIdentity: identity, completion: { (result: TCHResult, user: TCHUserDescriptor?) in
            if result.isSuccessful(), let user = user {
                user.subscribe(completion: { (result: TCHResult, user: TCHUser?) in
                    if result.isSuccessful() {
                        flutterResult(Mapper.userToDict(user))
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "Error subscribing to user with identity: \(identity)", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving user descriptor for identity: \(identity)", details: nil))
            }
        })
    }
}

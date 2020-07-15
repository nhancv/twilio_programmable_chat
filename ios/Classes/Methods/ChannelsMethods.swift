import Flutter
import Foundation
import TwilioChatClient

public class ChannelsMethods {
    public static func createChannel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let friendlyName = arguments["friendlyName"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'friendlyName' parameter", details: nil))
        }

        guard let channelTypeString = arguments["channelType"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelType' parameter", details: nil))
        }

        guard let channelType = Mapper.stringToChannelType(channelTypeString) else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Could no parse 'channelType' parameter", details: nil))
        }

        let channelOptions: [String: Any?] = [
            TCHChannelOptionFriendlyName: friendlyName,
            TCHChannelOptionType: channelType.rawValue
        ]

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.createChannel(options: channelOptions, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.createChannel => onSuccess")
                flutterResult(Mapper.channelToDict(channel))
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.createChannel => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error creating channel with friendlyName '\(friendlyName)': \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getChannel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSidOrUniqueName = arguments["channelSidOrUniqueName"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSidOrUniqueName' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSidOrUniqueName, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.getChannel => onSuccess")
                flutterResult(Mapper.channelToDict(channel))
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.getChannel => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid or uniqueName '\(channelSidOrUniqueName)'", details: nil))
            }
        })
    }

    public static func getPublicChannelsList(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.publicChannelDescriptors(completion: { (result: TCHResult, paginator: TCHChannelDescriptorPaginator?) in
            if result.isSuccessful(), let paginator = paginator {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.getPublicChannelsList => onSuccess")
                let pageId = PaginatorManager.setPaginator(paginator)
                flutterResult(Mapper.channelDescriptorsToDict(pageId, paginator))
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.getPublicChannelsList => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving public channels list", details: nil))
            }
        })
    }

    public static func getUserChannelsList(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.userChannelDescriptors(completion: { (result: TCHResult, paginator: TCHChannelDescriptorPaginator?) in
            if result.isSuccessful(), let paginator = paginator {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.getUserChannelsList => onSuccess")
                let pageId = PaginatorManager.setPaginator(paginator)
                flutterResult(Mapper.channelDescriptorsToDict(pageId, paginator))
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelsMethods.getUserChannelsList => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving user channels list", details: nil))
            }
        })
    }

    public static func getMembersByIdentity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        var membersList: [[String: Any?]] = []
        // TODO: Get all channels - Public and User and get members across them
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.subscribedChannels().forEach({ (channel: TCHChannel) in
            if let member = channel.member(withIdentity: identity) {
                membersList.append(Mapper.memberToDict(member, channelSid: channel.sid))
            }
        })
        result(membersList)
    }
}

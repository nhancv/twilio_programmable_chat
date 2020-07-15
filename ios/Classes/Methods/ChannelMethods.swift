import Flutter
import Foundation
import TwilioChatClient

// swiftlint:disable type_body_length
public class ChannelMethods {
    public static func join(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.join => onSuccess")
                channel.join { (result: TCHResult) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.join (Channel.join) => onSuccess")
                        flutterResult(nil)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.join (Channel.join) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error joining channel (Channel.join) with sid \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.join => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error joining channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func leave(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.leave => onSuccess")
                channel.leave { (result: TCHResult) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.leave (Channel.leave) => onSuccess")
                        flutterResult(nil)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.leave (Channel.leave) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.leave => Error leaving channel (Channel.leave) with sid \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.leave => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.leave => Error leaving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func typing(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.typing => onSuccess")
                channel.typing()
                flutterResult(nil)
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.typing => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.typing => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func declineInvitation(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation => onSuccess")
                channel.declineInvitation { (result: TCHResult) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation (Channel.declineInvitation) => onSuccess")
                        flutterResult(nil)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation (Channel.declineInvitation) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.declineInvitation => Error declining invitation for \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.declineInvitation => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func destroy(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.destroy => onSuccess")
                channel.destroy(completion: { (result: TCHResult) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.destroy (Channel.destroy) => onSuccess")
                        flutterResult(nil)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.destroy (Channel.destroy) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.destroy => Error destroying channel \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.destroy => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.destroy => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getMessagesCount(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount => onSuccess")
                channel.getMessagesCount(completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount (Channel.getMessagesCount) => onSuccess: \(count)")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount (Channel.getMessagesCount) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getMessagesCount => Error retrieving message count for channel \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getMessagesCount => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getUnconsumedMessagesCount(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount => onSuccess")
                channel.getUnconsumedMessagesCount(completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount (Channel.getUnconsumedMessagesCount) => onSuccess: \(count)")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount (Channel.getUnconsumedMessagesCount) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getUnconsumedMessagesCount => Error retrieving unconsumed message count " +
                            "for channel \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getUnconsumedMessagesCount  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getMembersCount(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount => onSuccess")
                channel.getMembersCount(completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount (Channel.getMembersCount) => onSuccess: \(count)")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount (Channel.getMembersCount) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getMembersCount => Error retrieving member count for channel \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getMembersCount  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func setAttributes(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let attributesDict = arguments["attributes"] as? [String: Any?] else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        let attributes = TCHJsonAttributes.init(dictionary: attributesDict as [AnyHashable: Any])

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes => onSuccess")
                channel.setAttributes(attributes, completion: { (result: TCHResult) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes (Channel.setAttributes) => onSuccess")
                        flutterResult(Mapper.attributesToDict(attributes))
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes (Channel.setAttributes) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setAttributes => Error setting attributes for channel \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setAttributes  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getFriendlyName(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getFriendlyName => onSuccess")
                flutterResult(channel.friendlyName)
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getFriendlyName => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getFriendlyName  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func setFriendlyName(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let friendlyName = arguments["friendlyName"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setFriendlyName => onSuccess")
                channel.setFriendlyName(friendlyName) { (result: TCHResult) in
                    if result.isSuccessful() {
                        flutterResult(channel.friendlyName)
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setFriendlyName  => Error setting friendlyName for channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setFriendlyName => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setFriendlyName  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getNotificationLevel(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getNotificationLevel => onSuccess")
                flutterResult(channel.notificationLevel)
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getNotificationLevel => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getNotificationLevel  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func setNotificationLevel(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let notificationLevelString = arguments["notificationLevel"] as? String,
            let notificationLevel = Mapper.stringToChannelNotificationLevel(notificationLevelString) else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setNotificationLevel => onSuccess")

                channel.setNotificationLevel(notificationLevel, completion: { (result: TCHResult) in
                    if result.isSuccessful() {
                        flutterResult(Mapper.channelNotificationLevelToString(channel.notificationLevel))
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setNotificationLevel  => Error setting notificationLevel for channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setNotificationLevel => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setNotificationLevel  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func getUniqueName(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getUniqueName => onSuccess")
                flutterResult(channel.uniqueName)
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.getUniqueName => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.getUniqueName  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }

    public static func setUniqueName(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let uniqueName = arguments["uniqueName"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setUniqueName => onSuccess")

                channel.setUniqueName(uniqueName, completion: { (result: TCHResult) in
                    if result.isSuccessful() {
                        flutterResult(channel.uniqueName)
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setUniqueName  => Error setting uniqueName for channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
                    }
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("ChannelMethods.setUniqueName => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "ChannelMethods.setUniqueName  => Error retrieving channel with sid \(channelSid): \(String(describing: result.error))", details: nil))
            }
        })
    }
}

import Flutter
import Foundation
import TwilioChatClient

public class MessagesMethods {
    // swiftlint:disable:next cyclomatic_complexity
    public static func sendMessage(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let options = arguments["options"] as? [String: Any],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        let messageOptions = TCHMessageOptions(), mediaProgressListenerId = options["mediaProgressListenerId"]

        if let bodyRaw = options["body"], let body = bodyRaw as? String {
            messageOptions.withBody(body)
        }

        if let attributes = options["attributes"] as? [String: Any?] {
            messageOptions.withAttributes(Mapper.dictToAttributes(attributes)) { (result: TCHResult) in
                if !result.isSuccessful() {
                    flutterResult(FlutterError(code: "ERROR", message: "Failed to set attributes on message with error: \(String(describing: result.error))", details: nil))
                }
            }
        }

        if let input = options["input"] as? String {
            guard let mimeType = options["mimeType"] as? String else {
                return flutterResult(FlutterError(code: "ERROR", message: "Missing 'mimeType' in MessageOptions", details: nil))
            }

            if let inputStream = InputStream(fileAtPath: input) {
                messageOptions.withMediaStream(inputStream, contentType: mimeType, defaultFilename: options["filename"] as? String,
                                               onStarted: {
                                                if let id = mediaProgressListenerId, let sink = SwiftTwilioProgrammableChatPlugin.mediaProgressSink {
                                                    sink(["mediaProgressListenerId": id, "name": "started"])
                                                }},
                                               onProgress: { (bytes: UInt) in
                                                if let id = mediaProgressListenerId, let sink = SwiftTwilioProgrammableChatPlugin.mediaProgressSink {
                                                    sink(["mediaProgressListenerId": id, "name": "progress", "data": bytes])
                                                }},
                                               onCompleted: { (mediaSid: String) in
                                                if let id = mediaProgressListenerId, let sink = SwiftTwilioProgrammableChatPlugin.mediaProgressSink {
                                                    sink(["mediaProgressListenerId": id, "name": "completed", "data": mediaSid])
                                                }})
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving file for upload from `\(input)`", details: nil))
            }
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.sendMessage(with: messageOptions, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful(), let message = message {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Message.sendMessage) => onSuccess")
                        flutterResult(Mapper.messageToDict(message, channelSid: channelSid))
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Message.sendMessage) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error sending message with options `\(String(describing: messageOptions))`", details: nil))
                    }
                })
            }
        })
    }

    public static func removeMessage(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let messageIndex = arguments["messageIndex"] as? NSNumber else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.message(withIndex: messageIndex, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful(), let message = message {
                        channel.messages?.remove(message, completion: { (result: TCHResult) in
                            if result.isSuccessful() {
                                SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.removeMessage) => onSuccess")
                                flutterResult(nil)
                            } else {
                                SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.removeMessage) => onError: \(String(describing: result.error))")
                                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving message (index: \(channelSid)) from channel (sid: \(channelSid))", details: nil))
                            }
                        })
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.messageWithIndex) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving message (index: \(channelSid)) from channel (sid: \(channelSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func getMessagesBefore(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let index = arguments["index"] as? UInt,
            let count = arguments["count"] as? UInt else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.getBefore(index, withCount: count, completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful(), let messages = messages {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesBefore (Messages.getBefore) => onSuccess")
                        let messagesMap = messages.map { (message: TCHMessage) -> [String: Any?] in
                            return Mapper.messageToDict(message, channelSid: channelSid)
                        }
                        flutterResult(messagesMap)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesBefore (Messages.getBefore) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving \(count) messages before message (index: \(index)) from channel (sid: \(channelSid))", details: nil))
                    }
                })
            }
        })
    }

    public static func getMessagesAfter(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let index = arguments["index"] as? UInt,
            let count = arguments["count"] as? UInt else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.getAfter(index, withCount: count, completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful(), let messages = messages {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesAfter (Messages.getAfter) => onSuccess")
                        let messagesMap = messages.map { (message: TCHMessage) -> [String: Any?] in
                            return Mapper.messageToDict(message, channelSid: channelSid)
                        }
                        flutterResult(messagesMap)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesAfter (Messages.getAfter) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving \(count) messages after message (index: \(index)) from channel (sid: \(channelSid))", details: nil))
                    }
                })
            }
        })
    }

    public static func getLastMessages(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let count = arguments["count"] as? UInt,
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.getLastWithCount(count, completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful(), let messages = messages {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.getLastMessages (Messages.getLast) => onSuccess")
                        let messagesMap = messages.map({ (message: TCHMessage) -> [String: Any?] in
                            return Mapper.messageToDict(message, channelSid: channelSid)
                        })
                        flutterResult(messagesMap)
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving last \(count) messages for channel with sid '\(channelSid)'", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func getMessageByIndex(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let messageIndex = arguments["messageIndex"] as? NSNumber else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.message(withIndex: messageIndex, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful(), let message = message {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.getMessageByIndex (Messages.messageWithIndex) => onSuccess")
                        flutterResult(Mapper.messageToDict(message, channelSid: channelSid))
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.messageWithIndex) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving message (index: \(channelSid)) from channel (sid: \(channelSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func setLastConsumedMessageIndexWithResult(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let lastConsumedMessageIndex = arguments["lastConsumedMessageIndex"] as? NSNumber else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel, let messages = channel.messages {
                messages.setLastConsumedMessageIndex(lastConsumedMessageIndex, completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.setLastConsumedMessageIndexWithResult (Messages.setLastConsumedMessageIndex) => onSuccess")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.setLastConsumedMessageIndexWithResult (Messages.setLastConsumedMessageIndex) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error setting last consumed message index (index: \(lastConsumedMessageIndex)) for channel (sid: \(channelSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func advanceLastConsumedMessageIndexWithResult(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let lastConsumedMessageIndex = arguments["lastConsumedMessageIndex"] as? NSNumber else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.advanceLastConsumedMessageIndex(lastConsumedMessageIndex, completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.advanceLastConsumedMessageIndexWithResult (Messages.advanceLastConsumedMessageIndex) => onSuccess")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.advanceLastConsumedMessageIndexWithResult (Messages.advanceLastConsumedMessageIndex) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error advancing last consumed message index (index: \(lastConsumedMessageIndex)) for channel with sid '\(channelSid)'", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func setAllMessagesConsumedWithResult(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.setAllMessagesConsumedWithCompletion({ (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.setAllMessagesConsumedWithResult (Messages.setAllMessagesConsumed) => onSuccess")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.setAllMessagesConsumedWithResult (Messages.setAllMessagesConsumed) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error setting all messages consumed for channel (sid: \(channelSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func setNoMessagesConsumedWithResult(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel, let messages = channel.messages {
                messages.setNoMessagesConsumedWithCompletion({ (result: TCHResult, count: UInt) in
                    if result.isSuccessful() {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.setNoMessagesConsumedWithResult (Messages.setNoMessagesConsumed) => onSuccess")
                        flutterResult(count)
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessagesMethods.setNoMessagesConsumedWithResult (Messages.setNoMessagesConsumed) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error setting no messages consumed for channel (sid: \(channelSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }
}

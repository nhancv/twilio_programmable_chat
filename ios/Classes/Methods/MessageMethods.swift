import Flutter
import Foundation
import TwilioChatClient

public class MessageMethods {
    public static func updateMessageBody(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        guard let messageIndex = arguments["messageIndex"] as? NSNumber else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'messageIndex' parameter", details: nil))
        }

        guard let body = arguments["body"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'body' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Channels.getChannel) => onSuccess")
                channel.messages?.message(withIndex: messageIndex, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful(), let message = message {
                        SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Messages.messageWithIndex) => onSuccess")
                        message.updateBody(body) { (result: TCHResult) in
                            if result.isSuccessful() {
                                SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Message.updateMessageBody) => onSuccess")
                                flutterResult(message.body)
                            }
                        }
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Messages.messageWithIndex) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving message (index: \(messageIndex)) from channel (sid: \(channelSid)", details: nil))
                    }
                })
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody => onError: \(error)")
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel (sid: \(channelSid))", details: nil))
                }
            }
        })
    }

    public static func setAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        guard let messageIndex = arguments["messageIndex"] as? NSNumber else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'messageIndex' parameter", details: nil))
        }

        guard let attributesDict = arguments["attributes"] as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'attributes' parameter", details: nil))
        }

        let attributes = TCHJsonAttributes.init(dictionary: attributesDict as [AnyHashable: Any])

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes => onSuccess")
                channel.messages?.message(withIndex: messageIndex, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful(), let message = message {
                        SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes (Messages.messageWithIndex) => onSuccess")
                        message.setAttributes(attributes) { (result: TCHResult) in
                            if result.isSuccessful() {
                                SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes (Message.setAttributes) => onSuccess")
                                flutterResult(Mapper.attributesToDict(message.attributes()))
                            } else {
                                SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes (Message.setAttributes) => onError: \(String(describing: result.error))")
                            }
                        }
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes (Messages.messageWithIndex) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving message (index: \(messageIndex)) from channel (sid: \(channelSid)", details: nil))
                    }
                })
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes => onError: \(error)")
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid or uniqueName '\(channelSid)'", details: nil))
                }
            }
        })
    }

    public static func getMedia(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let channelSid = arguments["channelSid"] as? String,
            let messageIndex = arguments["messageIndex"] as? NSNumber,
            let path = arguments["filePath"] as? String else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        let manager = FileManager.default

        var fileSize: UInt64
        do {
            let attr = try manager.attributesOfItem(atPath: path) as NSDictionary
            fileSize = attr.fileSize()
        } catch {
            fileSize = 0
        }

        if manager.fileExists(atPath: path), fileSize > 0 {
            flutterResult(true)
        } else {
            SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
                if result.isSuccessful(), let channel = channel {
                    channel.messages?.message(withIndex: messageIndex, completion: { (result: TCHResult, message: TCHMessage?) in
                        if result.isSuccessful(), let message = message {
                            let url = URL(fileURLWithPath: path)
                            if let outputStream = OutputStream(url: url, append: false) {
                                message.getMediaWith(outputStream, onStarted: {
                                    SwiftTwilioProgrammableChatPlugin.debug("getMediaWith => onStarted")
                                }, onProgress: { (bytes: UInt) in
                                    SwiftTwilioProgrammableChatPlugin.debug("getMediaWith => onProgress: \(bytes)")
                                }, onCompleted: { (mediaSid: String) in
                                    SwiftTwilioProgrammableChatPlugin.debug("getMediaWith => onCompleted: \(mediaSid)")
                                }, completion: { (result: TCHResult) in
                                    SwiftTwilioProgrammableChatPlugin.debug("getMediaWith => completion: \(result.isSuccessful())")
                                    flutterResult(result.isSuccessful())
                                })
                            } else {
                                flutterResult(FlutterError(code: "ERROR", message: "Error opening file at path '\(path)'", details: nil))
                            }
                        } else {
                            flutterResult(FlutterError(code: "ERROR", message: "Error retrieving message with index '\(messageIndex)'", details: nil))
                        }
                    })
                } else {
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
                }
            })
        }
    }
}

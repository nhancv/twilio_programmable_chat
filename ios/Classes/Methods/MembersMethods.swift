import Flutter
import Foundation
import TwilioChatClient

public class MembersMethods {
    public static func getMembersList(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.members?.members(completion: { (result: TCHResult, paginator: TCHMemberPaginator?) in
                    if result.isSuccessful(), let paginator = paginator {
                        return accumulateMembersListPages(accumulatedMembersList: [], paginator: paginator, channelSid: channelSid, result: flutterResult)
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving membersList for channel '\(channelSid)'", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    static func accumulateMembersListPages(accumulatedMembersList: [TCHMember], paginator: TCHMemberPaginator, channelSid: String, result flutterResult: @escaping FlutterResult) {
        var membersList: [TCHMember] = []
        membersList.append(contentsOf: accumulatedMembersList)
        membersList.append(contentsOf: paginator.items())
        if paginator.hasNextPage() {
            paginator.requestNextPage { (result: TCHResult, paginator: TCHMemberPaginator?) in
                if result.isSuccessful(), let paginator = paginator {
                    accumulateMembersListPages(accumulatedMembersList: membersList, paginator: paginator, channelSid: channelSid, result: flutterResult)
                } else {
                    flutterResult(FlutterError(code: "ERROR", message: "Error accumulating membersList", details: nil))
                }
            }
        } else {
            flutterResult(Mapper.membersListToDict(membersList, channelSid: channelSid))
        }
    }

    public static func getMember(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                if let member = channel.member(withIdentity: identity) {
                    flutterResult(Mapper.memberToDict(member, channelSid: channelSid))
                } else {
                    flutterResult(nil)
                }
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel with sid '\(channelSid)'", details: nil))
            }
        })
    }

    public static func addByIdentity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Channels.getChannel) => onSuccess")
                channel.members?.add(byIdentity: identity, completion: { (result: TCHResult) in
                    if let error = result.error {
                        SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Members.addByIdentity) => onError: \(error)")
                        flutterResult(FlutterError(code: "ERROR", message: "Error adding member (sid: \(identity)) to channel (sid: \(channelSid))", details: nil))
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Members.addByIdentity) => onCompletion: \(result.isSuccessful())")
                        flutterResult(result.isSuccessful())
                    }
                })
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity => onError: \(error)")
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel (sid: \(channelSid))", details: nil))
                }
            }
        })
    }

    public static func inviteByIdentity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Channels.getChannel) => onSuccess")
                channel.members?.invite(byIdentity: identity, completion: { (result: TCHResult) in
                    if let error = result.error {
                        SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Members.inviteByIdentity) => onError: \(error)")
                        flutterResult(FlutterError(code: "ERROR", message: "Error inviting member (sid: \(identity)) to channel (sid: \(channelSid))", details: nil))
                    } else {
                        SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Members.inviteByIdentity) => onCompletion: \(result.isSuccessful())")
                        flutterResult(result.isSuccessful())
                    }
                })
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity => onError: \(error)")
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel (sid: \(channelSid))", details: nil))
                }
            }
        })
    }

    public static func removeByIdentity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let channelSid = arguments["channelSid"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'channelSid' parameter", details: nil))
        }

        guard let identity = arguments["identity"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'identity' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Channels.getChannel) => onSuccess")
                if let member = channel.member(withIdentity: identity) {
                    channel.members?.remove(member, completion: { (result: TCHResult) in
                        if let error = result.error {
                            SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Members.inviteByIdentity) => onError: \(error)")
                            flutterResult(FlutterError(code: "ERROR", message: "Error removing member (sid: \(identity)) from channel (sid: \(channelSid))", details: nil))
                        } else {
                            SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Members.inviteByIdentity) => onCompletion: \(result.isSuccessful())")
                            flutterResult(result.isSuccessful())
                        }
                    })
                } else {
                    SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Channel.memberWithIdentity) => onError")
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving member (sid: \(identity)) from channel (sid: \(channelSid))", details: nil))
                }
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity => onError: \(error)")
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving channel (sid: \(channelSid))", details: nil))
                }
            }
        })
    }
}

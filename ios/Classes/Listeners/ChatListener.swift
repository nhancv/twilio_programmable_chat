import Flutter
import Foundation
import TwilioChatClient

public class ChatListener: NSObject, TwilioChatClientDelegate {
    public var events: FlutterEventSink?

    public var clientProperties: TwilioChatClientProperties

    public var chatClient: TwilioChatClient?

    init(_ token: String, _ properties: TwilioChatClientProperties) {
        self.clientProperties = properties
    }

    // onAddedToChannel Notification
    public func chatClient(_ client: TwilioChatClient, notificationAddedToChannelWithSid channelSid: String) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onAddedToChannelNotification => channelSid is \(channelSid)'")
        sendEvent("addedToChannelNotification", data: ["channelSid": channelSid])
    }

    // onChannelAdded / onChannelInvited
    public func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {
        if channel.status == TCHChannelStatus.invited {
            SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onChannelInvited => channelSid is \(String(describing: channel.sid))'")
            sendEvent("channelInvited", data: ["channel": Mapper.channelToDict(channel) as Any])
        } else if channel.status == TCHChannelStatus.joined {
            SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onChannelJoined => channelSid is \(String(describing: channel.sid))'")
            sendEvent("channelJoined", data: ["channel": Mapper.channelToDict(channel) as Any])
        } else {
            SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onChannelAdded => channelSid is \(String(describing: channel.sid))'")
            sendEvent("channelAdded", data: ["channel": Mapper.channelToDict(channel) as Any])
        }
    }

    // onChannelDeleted
    public func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onChannelDeleted => channelSid is \(String(describing: channel.sid))'")
        sendEvent("channelDeleted", data: ["channel": Mapper.channelToDict(channel) as Any])
    }

    // onChannelSynchronizationChanged
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onChannelSynchronizationChange => channelSid is '\(String(describing: channel.sid))', syncStatus: \(Mapper.channelSynchronizationStatusToString(channel.synchronizationStatus))")
        sendEvent("channelSynchronizationChange", data: ["channel": Mapper.channelToDict(channel) as Any])
    }

    // onChannelUpdated
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, updated: TCHChannelUpdate) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.channelUpdated => channelSid is \(String(describing: channel.sid)) updated, \(Mapper.channelUpdateToString(updated))")
        sendEvent("channelUpdated", data: [
            "channel": Mapper.channelToDict(channel) as Any,
            "reason": [
                "type": "channel",
                "value": Mapper.channelUpdateToString(updated)
            ]
        ])
    }

    // onClientSynchronizationUpdated
    public func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onClientSynchronization => state is \(Mapper.clientSynchronizationStatusToString(status))")
        sendEvent("connectionStateChange", data: ["synchronizationStatus": Mapper.clientSynchronizationStatusToString(status)])
    }

    // onConnectionStateChange
    public func chatClient(_ client: TwilioChatClient, connectionStateUpdated state: TCHClientConnectionState) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onConnectionStateChange => state is \(Mapper.clientConnectionStateToString(state))")
        sendEvent("connectionStateChange", data: ["connectionState": Mapper.clientConnectionStateToString(state)])
    }

    // onError
    public func chatClient(_ client: TwilioChatClient, errorReceived error: TCHError) {
        sendEvent("error", error: error)
    }

    // onInvitedToChannelNotification
    public func chatClient(_ client: TwilioChatClient, notificationInvitedToChannelWithSid channelSid: String) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onInvitedToChannelNotification => channelSid is \(channelSid)")
        sendEvent("invitedToChannelNotification", data: ["channelSid": channelSid])
    }

    // onNewMessageNotification
    public func chatClient(_ client: TwilioChatClient, notificationNewMessageReceivedForChannelSid channelSid: String, messageIndex: UInt) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onNewMessageNotification => channelSid: \(channelSid), messageIndex: \(messageIndex)")
        var messageSid: String = ""
        client.channelsList()?.channel(withSidOrUniqueName: channelSid, completion: { (result: TCHResult, channel: TCHChannel?) in
            if result.isSuccessful(), let channel = channel {
                channel.messages?.message(withIndex: messageIndex as NSNumber, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful(), let sid = message?.sid {
                        messageSid = sid
                    }
                })
            }
        })
        sendEvent("newMessageNotification", data: [
            "channelSid": channelSid,
            "messageSid": messageSid,
            "messageIndex": messageIndex
        ])
    }

    // TODO: Push notification registration/callback

    // onRemovedFromChannelNotification
    public func chatClient(_ client: TwilioChatClient, notificationRemovedFromChannelWithSid channelSid: String) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onRemovedFromChannelNotification => channelSid: \(channelSid)")
        sendEvent("removedFromChannelNotification", data: ["channelSid": channelSid])
    }

    // onTokenAboutToExpire
    public func chatClientTokenWillExpire(_ client: TwilioChatClient) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onTokenAboutToExpire")
        sendEvent("tokenAboutToExpire", data: nil)
    }

    // onTokenExpired
    public func chatClientTokenExpired(_ client: TwilioChatClient) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onTokenExpired")
        sendEvent("tokenExpired", data: nil)
    }

    // onUserSubscribed
    public func chatClient(_ client: TwilioChatClient, userSubscribed user: TCHUser) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onUserSubscribed => user '\(String(describing: user.identity))'")
        sendEvent("userSubscribed", data: ["user": Mapper.userToDict(user) as Any])
    }

    // onUserUnsubscribed
    public func chatClient(_ client: TwilioChatClient, userUnsubscribed user: TCHUser) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onUserUnsubscribed => user '\(String(describing: user.identity))'")
        sendEvent("userUnsubscribed", data: ["user": Mapper.userToDict(user) as Any])
    }

    // onUserUpdated
    public func chatClient(_ client: TwilioChatClient, user: TCHUser, updated: TCHUserUpdate) {
        SwiftTwilioProgrammableChatPlugin.debug("ChatListener.onUserUpdated => user \(String(describing: user.identity)) updated, \(Mapper.userUpdateToString(updated))")
        sendEvent("channelUpdated", data: [
            "channel": Mapper.userToDict(user) as Any,
            "reason": [
                "type": "user",
                "value": Mapper.userUpdateToString(updated)
            ]
        ])
    }

    private func errorToDict(_ error: Error?) -> [String: Any]? {
        if let error = error as NSError? {
            return [
                "code": error.code,
                "message": error.description
            ]
        }
        return nil
    }

    private func sendEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = ["name": name, "data": data, "error": errorToDict(error)] as [String: Any?]

        if let events = events {
            events(eventData)
        }
    }
}

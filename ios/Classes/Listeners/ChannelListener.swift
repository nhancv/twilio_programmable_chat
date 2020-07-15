import Flutter
import TwilioChatClient

public class ChannelListener: NSObject, TCHChannelDelegate {
    let events: FlutterEventSink

    init(_ events: @escaping FlutterEventSink) {
        self.events = events
    }

    // onMessageAdded
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMessageAdded => messageSid = \(String(describing: message.sid))")
        sendEvent("messageAdded", data: [
            "message": Mapper.messageToDict(message, channelSid: channel.sid)
        ])
    }

    // onMessageUpdated
    public func chatClient(
        _ client: TwilioChatClient, channel: TCHChannel, message: TCHMessage, updated: TCHMessageUpdate) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMessageUpdated => messageSid = \(String(describing: message.sid)), " +
            "updated = \(String(describing: updated))")
        sendEvent("messageUpdated", data: [
            "message": Mapper.messageToDict(message, channelSid: channel.sid),
            "reason": [
                "type": "message",
                "value": Mapper.messageUpdateToString(updated)
            ]
        ])
    }

    // onMessageDeleted
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageDeleted message: TCHMessage) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMessageDeleted => messageSid = \(String(describing: message.sid))")
        sendEvent("messageDeleted", data: [
            "message": Mapper.messageToDict(message, channelSid: channel.sid)
        ])
    }

    // onMemberAdded
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMemberAdded => memberSid = \(String(describing: member.sid))")
        sendEvent("memberAdded", data: [
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onMemberUpdated
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel,
                           member: TCHMember, updated: TCHMemberUpdate) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMemberUpdated => memberSid = \(String(describing: member.sid)), " +
            "updated = \(String(describing: updated))")
        sendEvent("memberUpdated", data: [
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any,
            "reason": [
                "type": "member",
                "value": Mapper.memberUpdateToString(updated)
            ]
        ])
    }

    // onMemberDeleted
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMemberDeleted => memberSid = \(String(describing: member.sid))")
        sendEvent("memberDeleted", data: [
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onTypingStarted
    public func chatClient(_ client: TwilioChatClient, typingStartedOn channel: TCHChannel, member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onTypingStarted => channelSid = \(String(describing: channel.sid)), " +
            "memberSid = \(String(describing: member.sid))")
        sendEvent("typingStarted", data: [
            "channel": Mapper.channelToDict(channel) as Any,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onTypingEnded
    public func chatClient(_ client: TwilioChatClient, typingEndedOn channel: TCHChannel, member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onTypingEnded => channelSid = \(String(describing: channel.sid)), " +
            "memberSid = \(String(describing: member.sid))")
        sendEvent("typingEnded", data: [
            "channel": Mapper.channelToDict(channel) as Any,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onSynchronizationChanged
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel,
                           synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onSynchronizationChanged => channelSid = \(String(describing: channel.sid))")
        sendEvent("synchronizationChanged", data: [
            "channel": Mapper.channelToDict(channel) as Any
        ])
    }

    private func sendEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = [
            "name": name,
            "data": data,
            "error": Mapper.errorToDict(error)
            ] as [String: Any?]

        events(eventData)
    }
}

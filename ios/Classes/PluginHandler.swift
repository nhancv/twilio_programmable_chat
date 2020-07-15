import Flutter
import Foundation
import TwilioChatClient

public class PluginHandler {
    // swiftlint:disable:next function_body_length
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SwiftTwilioProgrammableChatPlugin.debug("PluginHandler.handle => received \(call.method)")
        switch call.method {
        case "debug":
            debug(call, result: result)
        case "create":
            create(call, result: result)
        case "ChatClient#updateToken":
            ChatClientMethods.updateToken(call, result: result)
        case "ChatClient#shutdown":
            ChatClientMethods.shutdown(call, result: result)
//        case "ChatClient#registerForNotification":
//            ChatClientMethods.registerForNotification(call, result: result)
//        case "ChatClient#unregisterForNotification":
//            ChatClientMethods.unregisterForNotification(call, result: result)

        case "User#unsubscribe":
            UserMethods.unsubscribe(call, result: result)

        case "Users#getChannelUserDescriptors":
            UsersMethods.getChannelUserDescriptors(call, result: result)
        case "Users#getUserDescriptor":
            UsersMethods.getUserDescriptor(call, result: result)
        case "Users#getAndSubscribeUser":
            UsersMethods.getAndSubscribeUser(call, result: result)

        case "Channel#join":
            ChannelMethods.join(call, result: result)
        case "Channel#leave":
            ChannelMethods.leave(call, result: result)
        case "Channel#typing":
            ChannelMethods.typing(call, result: result)
        case "Channel#declineInvitation":
            ChannelMethods.declineInvitation(call, result: result)
        case "Channel#destroy":
            ChannelMethods.destroy(call, result: result)
        case "Channel#getMessagesCount":
            ChannelMethods.getMessagesCount(call, result: result)
        case "Channel#getUnconsumedMessagesCount":
            ChannelMethods.getUnconsumedMessagesCount(call, result: result)
        case "Channel#getMembersCount":
            ChannelMethods.getMembersCount(call, result: result)
        case "Channel#setAttributes":
            ChannelMethods.setAttributes(call, result: result)
        case "Channel#getFriendlyName":
            ChannelMethods.getFriendlyName(call, result: result)
        case "Channel#setFriendlyName":
            ChannelMethods.setFriendlyName(call, result: result)
        case "Channel#getNotificationLevel":
            ChannelMethods.getNotificationLevel(call, result: result)
        case "Channel#setNotificationLevel":
            ChannelMethods.setNotificationLevel(call, result: result)
        case "Channel#getUniqueName":
            ChannelMethods.getUniqueName(call, result: result)
        case "Channel#setUniqueName":
            ChannelMethods.setUniqueName(call, result: result)

        case "Channels#createChannel":
            ChannelsMethods.createChannel(call, result: result)
        case "Channels#getChannel":
            ChannelsMethods.getChannel(call, result: result)
        case "Channels#getPublicChannelsList":
            ChannelsMethods.getPublicChannelsList(call, result: result)
        case "Channels#getUserChannelsList":
            ChannelsMethods.getUserChannelsList(call, result: result)
        case "Channels#getMembersByIdentity":
            ChannelsMethods.getMembersByIdentity(call, result: result)

        case "Member#getUserDescriptor":
            MemberMethods.getUserDescriptor(call, result: result)
        case "Member#getAndSubscribeUser":
            MemberMethods.getAndSubscribeUser(call, result: result)
        case "Member#setAttributes":
            MemberMethods.setAttributes(call, result: result)

        case "Members#getMembersList":
            MembersMethods.getMembersList(call, result: result)
        case "Members#getMember":
            MembersMethods.getMember(call, result: result)
        case "Members#addByIdentity":
            MembersMethods.addByIdentity(call, result: result)
        case "Members#inviteByIdentity":
            MembersMethods.inviteByIdentity(call, result: result)
        case "Members#removeByIdentity":
            MembersMethods.removeByIdentity(call, result: result)

        case "Message#updateMessageBody":
            MessageMethods.updateMessageBody(call, result: result)
        case "Message#setAttributes":
            MessageMethods.setAttributes(call, result: result)
        case "Message#getMedia":
            MessageMethods.getMedia(call, result: result)

        case "Messages#sendMessage":
            MessagesMethods.sendMessage(call, result: result)
        case "Messages#removeMessage":
            MessagesMethods.removeMessage(call, result: result)
        case "Messages#getMessagesBefore":
            MessagesMethods.getMessagesBefore(call, result: result)
        case "Messages#getMessagesAfter":
            MessagesMethods.getMessagesAfter(call, result: result)
        case "Messages#getLastMessages":
            MessagesMethods.getLastMessages(call, result: result)
        case "Messages#getMessageByIndex":
            MessagesMethods.getMessageByIndex(call, result: result)
        case "Messages#setLastConsumedMessageIndexWithResult":
            MessagesMethods.setLastConsumedMessageIndexWithResult(call, result: result)
        case "Messages#advanceLastConsumedMessageIndexWithResult":
            MessagesMethods.advanceLastConsumedMessageIndexWithResult(call, result: result)
        case "Messages#setAllMessagesConsumedWithResult":
            MessagesMethods.setAllMessagesConsumedWithResult(call, result: result)
        case "Messages#setNoMessagesConsumedWithResult":
            MessagesMethods.setNoMessagesConsumedWithResult(call, result: result)

        case "Paginator#requestNextPage":
            PaginatorMethods.requestNextPage(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func debug(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let enableNative = arguments["native"] as? Bool else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'native' parameter", details: nil))
        }

        guard let enableSdk = arguments["sdk"] as? Bool else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'sdk' parameter", details: nil))
        }

        SwiftTwilioProgrammableChatPlugin.nativeDebug = enableNative
        if enableSdk {
            TwilioChatClient.setLogLevel(TCHLogLevel.debug)
        }
        result(enableNative)
    }

    private func create(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SwiftTwilioProgrammableChatPlugin.debug("TwilioProgrammableChatPlugin.create => called")

        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let token = arguments["token"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }

        guard let propertiesObj = arguments["properties"] as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }

        let properties = TwilioChatClientProperties()
        if let region = propertiesObj["region"] as? String {
            properties.region = region
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener = ChatListener(token, properties)
        TwilioChatClient.chatClient(withToken: token, properties: properties, delegate: SwiftTwilioProgrammableChatPlugin.chatListener, completion: {(result: TCHResult, chatClient: TwilioChatClient?) -> Void in
            if result.isSuccessful() {
                SwiftTwilioProgrammableChatPlugin.debug("TwilioProgrammableChatPlugin.create => ChatClient.create onSuccess: myIdentity is '\(chatClient?.user?.identity ?? "unknown")'")
                SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient = chatClient
                flutterResult(Mapper.chatClientToDict(chatClient))
            } else {
                SwiftTwilioProgrammableChatPlugin.debug("TwilioProgrammableChatPlugin.create => ChatClient.create onError: \(String(describing: result.error))")
            }
            } as TCHTwilioClientCompletion)
    }
}

import Flutter
import TwilioChatClient

// swiftlint:disable file_length type_body_length
public class Mapper {
    public static func chatClientToDict(_ chatClient: TwilioChatClient?) -> [String: Any] {
        return [
            "channels": channelsToDict(chatClient?.channelsList()) as Any,
            "myIdentity": chatClient?.user?.identity as Any,
            "connectionState": clientConnectionStateToString(chatClient?.connectionState),
            "users": usersToDict(chatClient?.users()),
            "isReachabilityEnabled": chatClient?.isReachabilityEnabled() as Any
        ]
    }

    public static func channelsToDict(_ channels: TCHChannels?) -> [String: Any]? {
        if let channels = channels {
            let subscribedChannelsMap = channels.subscribedChannels().map({ (channel: TCHChannel) -> [String: Any]? in
                return channelToDict(channel)
            })

            return [
                "subscribedChannels": subscribedChannelsMap
            ]
        }
        return nil
    }

    public static func channelToDict(_ channel: TCHChannel?) -> [String: Any]? {
        if let channel = channel as TCHChannel?, let sid = channel.sid {
            // TODO: determine if there's a more logical spot to do this initialization as setting up listeners isn't really the job of a mapper
            if !SwiftTwilioProgrammableChatPlugin.channelChannels.keys.contains(sid) {
                SwiftTwilioProgrammableChatPlugin.channelChannels[sid] = FlutterEventChannel(name: "twilio_programmable_chat/\(sid)", binaryMessenger: SwiftTwilioProgrammableChatPlugin.messenger!)
                SwiftTwilioProgrammableChatPlugin.channelChannels[sid]?.setStreamHandler(ChannelStreamHandler(channel))
            }

            return [
                "sid": sid,
                "type": channelTypeToString(channel.type),
                "messages": messagesToDict(channel.messages) as Any,
                "attributes": attributesToDict(channel.attributes()) as Any,
                "status": channelStatusToString(channel.status),
                "synchronizationStatus": channelSynchronizationStatusToString(channel.synchronizationStatus),
                "dateCreated": dateToString(channel.dateCreatedAsDate) as Any,
                "createdBy": channel.createdBy as Any,
                "dateUpdated": dateToString(channel.dateUpdatedAsDate) as Any,
                "lastMessageDate": dateToString(channel.lastMessageDate) as Any,
                "lastMessageIndex": channel.lastMessageIndex as Any
            ]
        } else {
            return nil
        }
    }

    public static func usersToDict(_ users: TCHUsers?) -> [String: Any?] {
        let subscribedUsersDict = users?.subscribedUsers().map({ (user: TCHUser) -> [String: Any]? in
            return userToDict(user)
        })
        return [
            "subscribedUsers": subscribedUsersDict,
            "myUser": userToDict(SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.user)
        ]
    }

    public static func userToDict(_ user: TCHUser?) -> [String: Any]? {
        if let user = user as TCHUser? {
            return [
                "friendlyName": user.friendlyName as Any,
                "attributes": attributesToDict(user.attributes()) as Any,
                "identity": user.identity as Any,
                "isOnline": user.isOnline(),
                "isNotifiable": user.isNotifiable(),
                "isSubscribed": user.isSubscribed()
            ]
        } else {
            return nil
        }
    }

    public static func userDescriptorsToDict(_ pageId: String, _ paginator: TCHUserDescriptorPaginator) -> [String: Any?] {
        let itemsListMap = paginator.items().map { (userDescriptor: TCHUserDescriptor) -> [String: Any?] in
            return userDescriptorToDict(userDescriptor)
        }

        return [
            "pageId": pageId,
            "pageSize": paginator.items().count,
            "hasNextPage": paginator.hasNextPage(),
            "items": itemsListMap,
            "itemType": "userDescriptor"
        ]
    }

    public static func userDescriptorToDict(_ userDescriptor: TCHUserDescriptor) -> [String: Any?] {
        return [
            "friendlyName": userDescriptor.friendlyName,
            "attributes": attributesToDict(userDescriptor.attributes()),
            "identity": userDescriptor.identity,
            "isOnline": userDescriptor.isOnline(),
            "isNotifiable": userDescriptor.isNotifiable()
        ]
    }

    public static func channelDescriptorsToDict(_ pageId: String, _ paginator: TCHChannelDescriptorPaginator) -> [String: Any?] {
        let channelDescriptorsMap = paginator.items().map { (channelDescriptor: TCHChannelDescriptor) -> [String: Any?] in
            return channelDescriptorToDict(channelDescriptor)
        }

        return [
            "pageId": pageId,
            "pageSize": paginator.items().count,
            "hasNextPage": paginator.hasNextPage(),
            "items": channelDescriptorsMap,
            "itemType": "channelDescriptor"
        ]
    }

    public static func channelDescriptorToDict(_ channelDescriptor: TCHChannelDescriptor) -> [String: Any?] {
        return [
            "sid": channelDescriptor.sid,
            "friendlyName": channelDescriptor.friendlyName,
            "attributes": attributesToDict(channelDescriptor.attributes()),
            "uniqueName": channelDescriptor.uniqueName,
            "dateUpdated": dateToString(channelDescriptor.dateUpdated),
            "dateCreated": dateToString(channelDescriptor.dateCreated),
            "createdBy": channelDescriptor.createdBy,
            "membersCount": channelDescriptor.membersCount(),
            "messagesCount": channelDescriptor.messagesCount()
        ]
    }

    public static func attributesToDict(_ attributes: TCHJsonAttributes?) -> [String: Any?]? {
        if let attr = attributes as TCHJsonAttributes? {
            if attr.isNull {
                return [
                    "type": "NULL",
                    "data": nil
                ]
            } else if attr.isNumber {
                return [
                    "type": "NUMBER",
                    "data": attr.number?.stringValue
                ]
            } else if attr.isArray {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.array as Any) else {
                    return nil
                }
                return [
                    "type": "ARRAY",
                    "data": String(data: jsonData, encoding: String.Encoding.utf8)
                ]
            } else if attr.isString {
                return [
                    "type": "STRING",
                    "data": attr.string
                ]
            } else if attr.isDictionary {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.dictionary as Any) else {
                    return nil
                }
                return [
                    "type": "OBJECT",
                    "data": String(data: jsonData, encoding: String.Encoding.utf8)
                ]
            }
        }
        return nil
    }

    public static func dictToAttributes(_ dict: [String: Any?]) -> TCHJsonAttributes {
        return TCHJsonAttributes.init(dictionary: dict as [AnyHashable: Any])
    }

    public static func messagesToDict(_ messages: TCHMessages?) -> [String: Any?]? {
        if let messages = messages {
            return [
                "lastConsumedMessageIndex": messages.lastConsumedMessageIndex
            ]
        }
        return nil
    }

    public static func messageToDict(_ message: TCHMessage, channelSid: String?) -> [String: Any?] {
        var memberDict: [String: Any?]?
        if let member = message.member {
            memberDict = memberToDict(member, channelSid: channelSid)
        }
        return [
            "sid": message.sid,
            "author": message.author,
            "dateCreated": message.timestamp,
            "messageBody": message.body,
            "channelSid": channelSid,
            "memberSid": message.memberSid,
            "member": memberDict,
            "messageIndex": message.index,
            "type": messageTypeToString(message.messageType),
            "hasMedia": message.hasMedia(),
            "media": mediaToDict(message, channelSid),
            "attributes": attributesToDict(message.attributes())
        ]
    }

    public static func mediaToDict(_ message: TCHMessage, _ channelSid: String?) -> [String: Any?]? {
        if !message.hasMedia() {
            return nil
        }
        return [
            "sid": message.mediaSid,
            "fileName": message.mediaFilename,
            "type": message.mediaType,
            "size": message.mediaSize,
            "channelSid": channelSid,
            "messageIndex": message.index
        ]
    }

    public static func membersListToDict(_ membersList: [TCHMember], channelSid: String) -> [String: [[String: Any?]]] {
        let membersListDict = membersList.map { (member: TCHMember) -> [String: Any?] in
            return memberToDict(member, channelSid: channelSid)
        }
        return ["membersList": membersListDict]
    }

    public static func memberToDict(_ member: TCHMember, channelSid: String?) -> [String: Any?] {
        return [
            "sid": member.sid,
            "lastConsumedMessageIndex": member.lastConsumedMessageIndex,
            "lastConsumptionTimestamp": member.lastConsumptionTimestamp,
            "channelSid": channelSid,
            "identity": member.identity,
            "type": memberTypeToString(member.type),
            "attributes": attributesToDict(member.attributes())
        ]
    }

    public static func errorToDict(_ error: Error?) -> [String: Any?]? {
        if let error = error as NSError? {
            return [
                "code": error.code,
                "message": error.description
            ]
        }

        return nil
    }

    public static func channelTypeToString(_ channelType: TCHChannelType) -> String {
        let channelTypeString: String

        switch channelType {
        case .private:
            channelTypeString = "PRIVATE"
        case .public:
            channelTypeString = "PUBLIC"
        @unknown default:
            channelTypeString = "UNKNOWN"
        }

        return channelTypeString
    }

    public static func stringToChannelType(_ channelTypeString: String?) -> TCHChannelType? {
        if let channelTypeString = channelTypeString {
            if channelTypeString == "PRIVATE" {
                return TCHChannelType.private
            } else if channelTypeString == "PUBLIC" {
                return TCHChannelType.public
            } else {
                return nil
            }
        }
        return nil
    }

    public static func channelStatusToString(_ channelStatus: TCHChannelStatus) -> String {
        let channelStatusString: String

        switch channelStatus {
        case .invited:
            channelStatusString = "INVITED"
        case .joined:
            channelStatusString = "JOINED"
        case .notParticipating:
            channelStatusString = "NOT_PARTICIPATING"
        case .unknown:
            channelStatusString = "UNKNOWN"
        @unknown default:
            channelStatusString = "UNKNOWN"
        }

        return channelStatusString
    }

    public static func clientConnectionStateToString(_ connectionState: TCHClientConnectionState?) -> String {
        var connectionStateString: String = "UNKNOWN"
        if let connectionState = connectionState {
            switch connectionState {
            case .unknown:
                connectionStateString = "UNKNOWN"
            case .disconnected:
                connectionStateString = "DISCONNECTED"
            case .connected:
                connectionStateString = "CONNECTED"
            case .connecting:
                connectionStateString = "CONNECTING"
            case .denied:
                connectionStateString = "DENIED"
            case .error:
                connectionStateString = "ERROR"
            case .fatalError:
                connectionStateString = "FATAL_ERROR"
            default:
                connectionStateString = "UNKNOWN"
            }
        }

        return connectionStateString
    }

    public static func clientSynchronizationStatusToString(_ syncStatus: TCHClientSynchronizationStatus?) -> String {
        var syncStateString: String = "UNKNOWN"
        if let syncStatus = syncStatus {
            switch syncStatus {
            case .started:
                syncStateString = "STARTED"
            case .channelsListCompleted:
                syncStateString = "CHANNELS_COMPLETED"
            case .completed:
                syncStateString = "COMPLETED"
            case .failed:
                syncStateString = "FAILED"
            default:
                syncStateString = "UNKNOWN"
            }
        }

        return syncStateString
    }

    public static func channelSynchronizationStatusToString(_ syncStatus: TCHChannelSynchronizationStatus) -> String {
        let syncStatusString: String

        switch syncStatus {
        case .none:
            syncStatusString = "NONE"
        case .identifier:
            syncStatusString = "IDENTIFIER"
        case .metadata:
            syncStatusString = "METADATA"
        case .all:
            syncStatusString = "ALL"
        case .failed:
            syncStatusString = "FAILED"
        @unknown default:
            syncStatusString = "UNKNOWN"
        }

        return syncStatusString
    }

    public static func memberTypeToString(_ memberType: TCHMemberType) -> String {
        let memberTypeString: String

        switch memberType {
        case .unset:
            memberTypeString = "UNSET"
        case .other:
            memberTypeString = "OTHER"
        case .chat:
            memberTypeString = "CHAT"
        case .sms:
            memberTypeString = "SMS"
        case .whatsapp:
            memberTypeString = "CHAT"
        @unknown default:
            memberTypeString = "UNKNOWN"
        }

        return memberTypeString
    }

    public static func messageTypeToString(_ messageType: TCHMessageType) -> String {
        let messageTypeString: String

        switch messageType {
        case .media:
            messageTypeString = "MEDIA"
        case .text:
            messageTypeString = "TEXT"
        @unknown default:
            messageTypeString = "UNKNOWN"
        }

        return messageTypeString
    }

    public static func messageUpdateToString(_ update: TCHMessageUpdate) -> String {
        let updateString: String

        switch update {
        case .attributes:
            updateString = "ATTRIBUTES"
        case .body:
            updateString = "BODY"
        @unknown default:
            updateString = "UNKNOWN"
        }

        return updateString
    }

    public static func memberUpdateToString(_ update: TCHMemberUpdate) -> String {
        let updateString: String

        switch update {
        case .attributes:
            updateString = "ATTRIBUTES"
        case .lastConsumedMessageIndex:
            updateString = "LAST_CONSUMED_MESSAGE_INDEX"
        @unknown default:
            updateString = "UNKNOWN"
        }

        return updateString
    }

    public static func dateToString(_ date: Date?) -> String? {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            return formatter.string(from: date)
        }
        return nil
    }

    public static func channelNotificationLevelToString(_ notificationLevel: TCHChannelNotificationLevel) -> String {
        switch notificationLevel {
        case .default:
            return "DEFAULT"
        case .muted:
            return "MUTED"
        @unknown default:
            return "UNKNOWN"
        }
    }

    public static func userUpdateToString(_ update: TCHUserUpdate) -> String {
        switch update {
        case .friendlyName:
            return "FRIENDLY_NAME"
        case .attributes:
            return "ATTRIBUTES"
        case .reachabilityOnline:
            return "REACHABILITY_ONLINE"
        case .reachabilityNotifiable:
            return "REACHABILITY_NOTIFIABLE"
        @unknown default:
            return "UNKNOWN"
        }
    }

    public static func channelUpdateToString(_ update: TCHChannelUpdate) -> String {
        switch update {
        case .status:
            return "STATUS"
        case .lastConsumedMessageIndex:
            return "LAST_CONSUMED_MESSAGE_INDEX"
        case .uniqueName:
            return "UNIQUE_NAME"
        case .friendlyName:
            return "FRIENDLY_NAME"
        case .attributes:
            return "ATTRIBUTES"
        case .lastMessage:
            return "LAST_MESSAGE"
        case .userNotificationLevel:
            return "NOTIFICATION_LEVEL"
        @unknown default:
            return "UNKNOWN"
        }
    }

    public static func stringToChannelNotificationLevel(_ notificationLevelString: String?) -> TCHChannelNotificationLevel? {
        if let notificationLevelString = notificationLevelString {
            switch notificationLevelString {
            case "DEFAULT":
                return TCHChannelNotificationLevel.default
            case "MUTED":
                return TCHChannelNotificationLevel.muted
            default:
                return nil
            }
        }
        return nil
    }

    class ChannelStreamHandler: NSObject, FlutterStreamHandler {
        let channel: TCHChannel

        init(_ channel: TCHChannel) {
            self.channel = channel
        }

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            if let sid = channel.sid {
                SwiftTwilioProgrammableChatPlugin.debug("Mapper.channelToDict => EventChannel for Channel($\(String(describing: sid)) attached")
                SwiftTwilioProgrammableChatPlugin.channelListeners[sid] = ChannelListener(events)
                channel.delegate = SwiftTwilioProgrammableChatPlugin.channelListeners[sid]
            }
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            if let sid = channel.sid {
                SwiftTwilioProgrammableChatPlugin.debug("Mapper.channelToDict => EventChannel for Channel($\(String(describing: sid)) detached")
                channel.delegate = nil
                SwiftTwilioProgrammableChatPlugin.channelListeners.removeValue(forKey: sid)
            }
            return nil
        }
    }
}

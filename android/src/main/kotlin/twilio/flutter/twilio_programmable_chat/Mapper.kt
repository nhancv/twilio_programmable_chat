package twilio.flutter.twilio_programmable_chat

import com.twilio.chat.Attributes
import com.twilio.chat.Channel
import com.twilio.chat.ChannelDescriptor
import com.twilio.chat.Channels
import com.twilio.chat.ChatClient
import com.twilio.chat.ErrorInfo
import com.twilio.chat.Member
import com.twilio.chat.Members
import com.twilio.chat.Message
import com.twilio.chat.Messages
import com.twilio.chat.Paginator
import com.twilio.chat.User
import com.twilio.chat.UserDescriptor
import com.twilio.chat.Users
import io.flutter.plugin.common.EventChannel
import java.text.SimpleDateFormat
import java.util.Date
import org.json.JSONArray
import org.json.JSONObject
import twilio.flutter.twilio_programmable_chat.listeners.ChannelListener

object Mapper {
    fun jsonObjectToMap(jsonObject: JSONObject): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        jsonObject.keys().forEach {
            if (jsonObject[it] == null || JSONObject.NULL == jsonObject[it]) {
                result[it] = null
            } else if (jsonObject[it] is JSONObject) {
                result[it] = jsonObjectToMap(jsonObject[it] as JSONObject)
            } else if (jsonObject[it] is JSONArray) {
                result[it] = jsonArrayToList(jsonObject[it] as JSONArray)
            } else {
                result[it] = jsonObject[it]
            }
        }
        return result
    }

    fun jsonArrayToList(jsonArray: JSONArray): List<Any?> {
        val result = mutableListOf<Any?>()
        for (i in 0 until jsonArray.length()) {
            if (jsonArray[i] == null || JSONObject.NULL == jsonArray[i]) {
                result[i] = null
            } else if (jsonArray[i] is JSONObject) {
                result[i] = jsonObjectToMap(jsonArray[i] as JSONObject)
            } else if (jsonArray[i] is JSONArray) {
                result[i] = jsonArrayToList(jsonArray[i] as JSONArray)
            } else {
                result[i] = jsonArray[i]
            }
        }
        return result
    }

    fun mapToJSONObject(map: Map<String, Any>?): JSONObject? {
        if (map == null) {
            return null
        }
        val result = JSONObject()
        map.keys.forEach {
            if (map[it] == null) {
                result.put(it, null)
            } else if (map[it] is Map<*, *>) {
                result.put(it, mapToJSONObject(map[it] as Map<String, Any>))
            } else if (map[it] is List<*>) {
                result.put(it, listToJSONArray(map[it] as List<Any>))
            } else {
                result.put(it, map[it])
            }
        }
        return result
    }

    fun mapToAttributes(map: Map<String, Any>?): Attributes? {
        if (map == null) return null
        val attrObject = mapToJSONObject(map)
        if (attrObject != null) return Attributes(attrObject) else return null
    }

    fun listToJSONArray(list: List<Any>): JSONArray {
        val result = JSONArray()
        list.forEach {
            if (it is Map<*, *>) {
                result.put(mapToJSONObject(it as Map<String, Any>))
            } else if (it is List<*>) {
                result.put(listToJSONArray(it as List<Any>))
            } else {
                result.put(it)
            }
        }
        return result
    }

    fun chatClientToMap(chatClient: ChatClient): Map<String, Any> {
        return mapOf(
                "properties" to propertiesToMap(chatClient.properties),
                "channels" to channelsToMap(chatClient.channels),
                "myIdentity" to chatClient.myIdentity,
                "connectionState" to chatClient.connectionState.toString(),
                "users" to usersToMap(chatClient.users),
                "isReachabilityEnabled" to chatClient.isReachabilityEnabled
        )
    }

    fun attributesToMap(attributes: Attributes): Map<String, Any> {
        return mapOf(
                "type" to attributes.type.toString(),
                "data" to attributes.toString()
        )
    }

    private fun propertiesToMap(properties: ChatClient.Properties): Map<String, Any> {
        return mapOf(
                "region" to properties.region,
                "deferCA" to properties.deferCA
        )
    }

    private fun channelsToMap(channels: Channels): Map<String, Any> {
        val subscribedChannelsMap = channels.subscribedChannels.map { channelToMap(it) }
        return mapOf(
                "subscribedChannels" to subscribedChannelsMap
        )
    }

    fun channelToMap(channel: Channel?, compareChannel: Channel? = null): Map<String, Any?>? {
        if (channel == null || compareChannel != null && channel.sid == compareChannel.sid) {
            return null
        }

        // Setting flutter event listener for the given channel if one does not yet exist.
        if (!TwilioProgrammableChatPlugin.channelChannels.containsKey(channel.sid)) {
            TwilioProgrammableChatPlugin.channelChannels[channel.sid] = EventChannel(TwilioProgrammableChatPlugin.messenger, "twilio_programmable_chat/${channel.sid}")
            TwilioProgrammableChatPlugin.channelChannels[channel.sid]?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    TwilioProgrammableChatPlugin.debug("Mapper.channelToMap => EventChannel for Channel(${channel.sid}) attached")
                    TwilioProgrammableChatPlugin.channelListeners[channel.sid] = ChannelListener(events)
                    channel.addListener(TwilioProgrammableChatPlugin.channelListeners[channel.sid])
                }

                override fun onCancel(arguments: Any) {
                    TwilioProgrammableChatPlugin.debug("Mapper.channelToMap => EventChannel for Channel(${channel.sid}) detached")
                    channel.removeListener(TwilioProgrammableChatPlugin.channelListeners[channel.sid])
                    TwilioProgrammableChatPlugin.channelListeners.remove(channel.sid)
                }
            })
        }

        return mapOf(
                "sid" to channel.sid,
                "type" to channel.type.toString(),
                "messages" to messagesToMap(channel.messages),
                "attributes" to attributesToMap(channel.attributes),
                "status" to channel.status.toString(),
                "members" to membersToMap(channel.members, channel),
                "synchronizationStatus" to channel.synchronizationStatus.toString(),
                "dateCreated" to dateToString(channel.dateCreatedAsDate),
                "createdBy" to channel.createdBy,
                "dateUpdated" to dateToString(channel.dateUpdatedAsDate),
                "lastMessageDate" to dateToString(channel.lastMessageDate),
                "lastMessageIndex" to channel.lastMessageIndex
        )
    }

    private fun usersToMap(users: Users): Map<String, Any> {
        val subscribedUsersMap = users.subscribedUsers.map { userToMap(it) }
        return mapOf(
                "subscribedUsers" to subscribedUsersMap,
                "myUser" to userToMap(users.myUser)
        )
    }

    fun userToMap(user: User): Map<String, Any> {
        return mapOf(
                "friendlyName" to user.friendlyName,
                "attributes" to attributesToMap(user.attributes),
                "identity" to user.identity,
                "isOnline" to user.isOnline,
                "isNotifiable" to user.isNotifiable,
                "isSubscribed" to user.isSubscribed
        )
    }

    private fun messagesToMap(messages: Messages?): Map<String, Any>? {
        if (messages == null) return null
        return mapOf(
                "lastConsumedMessageIndex" to messages.lastConsumedMessageIndex
        )
    }

    fun messageToMap(message: Message): Map<String, Any?> {
        return mapOf(
                "sid" to message.sid,
                "author" to message.author,
                "dateCreated" to message.dateCreated,
                "messageBody" to message.messageBody,
                "channelSid" to message.channelSid,
                "memberSid" to message.memberSid,
                "member" to memberToMap(message.member),
                "messageIndex" to message.messageIndex,
                "type" to message.type.toString(),
                "hasMedia" to message.hasMedia(),
                "media" to mediaToMap(message.media),
                "attributes" to attributesToMap(message.attributes)
        )
    }

    private fun mediaToMap(media: Message.Media?): Map<String, Any>? {
        if (media == null) return null
        return mapOf(
                "sid" to media.sid,
                "fileName" to media.fileName,
                "type" to media.type,
                "size" to media.size
        )
    }

    fun membersToMap(members: Members?, partOfChannel: Channel): Map<String, Any?>? {
        if (members == null) return null
        val membersListMap = members.membersList.map { memberToMap(it, partOfChannel) }
        return mapOf(
                "channelSid" to members.channel.sid,
                "membersList" to membersListMap
        )
    }

    fun memberToMap(member: Member, partOfChannel: Channel? = null): Map<String, Any?> {
        return mapOf(
                "sid" to member.sid,
                "lastConsumedMessageIndex" to member.lastConsumedMessageIndex,
                "lastConsumptionTimestamp" to member.lastConsumptionTimestamp,
                "channelSid" to member.channel.sid,
                "identity" to member.identity,
                "type" to member.type.toString(),
                "attributes" to attributesToMap(member.attributes)
        )
    }

    inline fun <reified T> paginatorToMap(pageId: String, paginator: Paginator<T>, itemType: String): Map<String, Any> {
        val itemsListMap = paginator.items.map {
            when (itemType) {
                "userDescriptor" -> userDescriptorToMap(it as UserDescriptor)
                "channelDescriptor" -> channelDescriptorToMap(it as ChannelDescriptor)
                else -> throw Exception("Unknown item type received '$itemType'")
            }
        }

        return mapOf(
                "pageId" to pageId,
                "pageSize" to paginator.pageSize,
                "hasNextPage" to paginator.hasNextPage(),
                "items" to itemsListMap,
                "itemType" to itemType
        )
    }

    fun userDescriptorToMap(userDescriptor: UserDescriptor): Map<String, Any> {
        return mapOf(
                "friendlyName" to userDescriptor.friendlyName,
                "attributes" to attributesToMap(userDescriptor.attributes),
                "identity" to userDescriptor.identity,
                "isOnline" to userDescriptor.isOnline,
                "isNotifiable" to userDescriptor.isNotifiable
        )
    }

    fun channelDescriptorToMap(channelDescriptor: ChannelDescriptor): Map<String, Any?> {
        return mapOf(
                "sid" to channelDescriptor.sid,
                "friendlyName" to channelDescriptor.friendlyName,
                "attributes" to attributesToMap(channelDescriptor.attributes),
                "uniqueName" to channelDescriptor.uniqueName,
                "dateUpdated" to dateToString(channelDescriptor.dateUpdated),
                "dateCreated" to dateToString(channelDescriptor.dateCreated),
                "createdBy" to channelDescriptor.createdBy,
                "membersCount" to channelDescriptor.membersCount,
                "messagesCount" to channelDescriptor.messagesCount,
                "unconsumedMessagesCount" to channelDescriptor.unconsumedMessagesCount,
                "status" to channelDescriptor.status.toString()
        )
    }

    fun errorInfoToMap(e: ErrorInfo?): Map<String, Any?>? {
        if (e == null)
            return null
        return mapOf(
                "code" to e.code,
                "message" to e.message,
                "status" to e.status
        )
    }

    private fun dateToString(date: Date?): String? {
        if (date == null) return null
        val dateFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
        return dateFormat.format(date)
    }
}

package twilio.flutter.twilio_programmable_chat.listeners

import com.twilio.chat.Channel
import com.twilio.chat.ChatClient
import com.twilio.chat.ChatClientListener
import com.twilio.chat.ErrorInfo
import com.twilio.chat.User
import io.flutter.plugin.common.EventChannel
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

class ChatListener(val token: String, val properties: ChatClient.Properties) : ChatClientListener {
    var events: EventChannel.EventSink? = null

    var chatClient: ChatClient? = null

    override fun onAddedToChannelNotification(channelSid: String) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onAddedToChannelNotification => channelSid = $channelSid")
        sendEvent("addedToChannelNotification", mapOf("channelSid" to channelSid))
    }

    override fun onChannelAdded(channel: Channel) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onChannelAdded => sid = ${channel.sid}")
        sendEvent("channelAdded", mapOf("channel" to Mapper.channelToMap(channel)))
    }

    override fun onChannelDeleted(channel: Channel) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onChannelDeleted => sid = ${channel.sid}")
        sendEvent("channelDeleted", mapOf("channel" to Mapper.channelToMap(channel)))
    }

    override fun onChannelInvited(channel: Channel) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onChannelInvited => sid = ${channel.sid}")
        sendEvent("channelInvited", mapOf("channel" to Mapper.channelToMap(channel)))
    }

    override fun onChannelJoined(channel: Channel) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onChannelJoined => sid = ${channel.sid}")
        sendEvent("channelJoined", mapOf("channel" to Mapper.channelToMap(channel)))
    }

    override fun onChannelSynchronizationChange(channel: Channel) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onChannelSynchronizationChange => sid = ${channel.sid}")
        sendEvent("channelSynchronizationChange", mapOf("channel" to Mapper.channelToMap(channel)))
    }

    override fun onChannelUpdated(channel: Channel, reason: Channel.UpdateReason) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onChannelUpdated => channel '${channel.sid}' updated, $reason")
        sendEvent("channelUpdated", mapOf(
                "channel" to Mapper.channelToMap(channel),
                "reason" to mapOf(
                    "type" to "channel",
                    "value" to reason.toString()
                )
        ))
    }

    override fun onClientSynchronization(synchronizationStatus: ChatClient.SynchronizationStatus) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onClientSynchronization => status = $synchronizationStatus")
        sendEvent("clientSynchronization", mapOf("synchronizationStatus" to synchronizationStatus.toString()))
    }

    override fun onConnectionStateChange(connectionState: ChatClient.ConnectionState) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onConnectionStateChange => status = $connectionState")
        sendEvent("connectionStateChange", mapOf("connectionState" to connectionState.toString()))
    }

    override fun onError(errorInfo: ErrorInfo) {
        sendEvent("error", null, errorInfo)
    }

    override fun onInvitedToChannelNotification(channelSid: String) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onInvitedToChannelNotification => channelSid = $channelSid")
        sendEvent("invitedToChannelNotification", mapOf("channelSid" to channelSid))
    }

    override fun onNewMessageNotification(channelSid: String?, messageSid: String?, messageIndex: Long) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onNewMessageNotification => channelSid = $channelSid, messageSid = $messageSid, messageIndex = $messageIndex")
        sendEvent("invitedToChannelNotification", mapOf(
                "channelSid" to channelSid,
                "messageSid" to messageSid,
                "messageIndex" to messageIndex
        ))
    }

    override fun onNotificationSubscribed() {
        TwilioProgrammableChatPlugin.debug("ChatListener.onNotificationSubscribed")
        sendEvent("notificationSubscribed", null)
    }

    override fun onNotificationFailed(errorInfo: ErrorInfo) {
        sendEvent("notificationFailed", null, errorInfo)
    }

    override fun onRemovedFromChannelNotification(channelSid: String) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onRemovedFromChannelNotification => channelSid = $channelSid")
        sendEvent("removedFromChannelNotification", mapOf("channelSid" to channelSid))
    }

    override fun onTokenAboutToExpire() {
        TwilioProgrammableChatPlugin.debug("ChatListener.onTokenAboutToExpire")
        sendEvent("tokenAboutToExpire", null)
    }

    override fun onTokenExpired() {
        TwilioProgrammableChatPlugin.debug("ChatListener.onTokenExpired")
        sendEvent("tokenExpired", null)
    }

    override fun onUserSubscribed(user: User) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onUserSubscribed => user '${user.friendlyName}'")
        sendEvent("userSubscribed", mapOf("user" to Mapper.userToMap(user)))
    }

    override fun onUserUnsubscribed(user: User) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onUserUnsubscribed => user '${user.friendlyName}'")
        sendEvent("userUnsubscribed", mapOf("user" to Mapper.userToMap(user)))
    }

    override fun onUserUpdated(user: User, reason: User.UpdateReason) {
        TwilioProgrammableChatPlugin.debug("ChatListener.onUserUpdated => user '${user.friendlyName}' updated, $reason")
        sendEvent("userUpdated", mapOf(
                "user" to Mapper.userToMap(user),
                "reason" to mapOf(
                        "type" to "user",
                        "value" to reason.toString()
                )
        ))
    }

    private fun sendEvent(name: String, data: Any?, e: ErrorInfo? = null) {
        val eventData = mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e))
        events?.success(eventData)
    }
}

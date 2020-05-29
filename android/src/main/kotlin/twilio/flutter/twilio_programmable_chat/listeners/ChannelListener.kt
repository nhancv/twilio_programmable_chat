package twilio.flutter.twilio_programmable_chat.listeners

import com.twilio.chat.Channel
import com.twilio.chat.ChannelListener as TwilioChannelListener
import com.twilio.chat.ErrorInfo
import com.twilio.chat.Member
import com.twilio.chat.Message
import io.flutter.plugin.common.EventChannel
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

class ChannelListener(private val events: EventChannel.EventSink) : TwilioChannelListener {
    override fun onMessageAdded(message: Message) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onMessageAdded => messageSid = ${message.sid}")
        sendEvent("messageAdded", mapOf("message" to Mapper.messageToMap(message)))
    }

    override fun onMessageUpdated(message: Message, reason: Message.UpdateReason) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onMessageUpdated => messageSid = ${message.sid}, reason = $reason")
        sendEvent("messageUpdated", mapOf(
                "message" to Mapper.messageToMap(message),
                "reason" to mapOf(
                        "type" to "message",
                        "value" to reason.toString()
                )
        ))
    }

    override fun onMessageDeleted(message: Message) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onMessageDeleted => messageSid = ${message.sid}")
        sendEvent("messageDeleted", mapOf("message" to Mapper.messageToMap(message)))
    }

    override fun onMemberAdded(member: Member) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onMemberAdded => memberSid = ${member.sid}")
        sendEvent("memberAdded", mapOf("member" to Mapper.memberToMap(member)))
    }

    override fun onMemberUpdated(member: Member, reason: Member.UpdateReason) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onMemberUpdated => memberSid = ${member.sid}, reason = $reason")
        sendEvent("memberUpdated", mapOf(
                "member" to Mapper.memberToMap(member),
                "reason" to mapOf(
                        "type" to "member",
                        "value" to reason.toString()
                )
        ))
    }

    override fun onMemberDeleted(member: Member) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onMemberDeleted => memberSid = ${member.sid}")
        sendEvent("memberDeleted", mapOf("member" to Mapper.memberToMap(member)))
    }

    override fun onTypingStarted(channel: Channel, member: Member) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onTypingStarted => channelSid = ${channel.sid}, memberSid = ${member.sid}")
        sendEvent("typingStarted", mapOf("channel" to Mapper.channelToMap(channel), "member" to Mapper.memberToMap(member)))
    }

    override fun onTypingEnded(channel: Channel, member: Member) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onTypingEnded => channelSid = ${channel.sid}, memberSid = ${member.sid}")
        sendEvent("typingEnded", mapOf("channel" to Mapper.channelToMap(channel), "member" to Mapper.memberToMap(member)))
    }

    override fun onSynchronizationChanged(channel: Channel) {
        TwilioProgrammableChatPlugin.debug("ChannelListener.onSynchronizationChanged => channelSid = ${channel.sid}")
        sendEvent("synchronizationChanged", mapOf("channel" to Mapper.channelToMap(channel)))
    }

    private fun sendEvent(name: String, data: Any?, e: ErrorInfo? = null) {
        val eventData = mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e))
        events.success(eventData)
    }
}

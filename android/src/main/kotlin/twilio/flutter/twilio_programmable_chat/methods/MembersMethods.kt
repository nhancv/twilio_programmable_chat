package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.Channel
import com.twilio.chat.ErrorInfo
import com.twilio.chat.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object MembersMethods {
    fun getChannel(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
            ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.getChannel => onSuccess")
                result.success(Mapper.channelToMap(channel))
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.getChannel => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun addByIdentity(call: MethodCall, result: MethodChannel.Result) {
        val identity = call.argument<String>("identity")
                ?: return result.error("ERROR", "Missing 'identity'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Channels.getChannel) => onSuccess")
                channel.members.addByIdentity(identity, object : StatusListener() {
                    override fun onSuccess() {
                        TwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Members.addByIdentity) => onSuccess")
                        result.success(Mapper.membersToMap(channel.members, channel))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Members.addByIdentity) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.addByIdentity (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun inviteByIdentity(call: MethodCall, result: MethodChannel.Result) {
        val identity = call.argument<String>("identity")
                ?: return result.error("ERROR", "Missing 'identity'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Channels.getChannel) => onSuccess")
                channel.members.inviteByIdentity(identity, object : StatusListener() {
                    override fun onSuccess() {
                        TwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Members.inviteByIdentity) => onSuccess")
                        result.success(Mapper.membersToMap(channel.members, channel))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Members.inviteByIdentity) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.inviteByIdentity (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun removeByIdentity(call: MethodCall, result: MethodChannel.Result) {
        val identity = call.argument<String>("identity")
                ?: return result.error("ERROR", "Missing 'identity'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Channels.getChannel) => onSuccess")
                channel.members.removeByIdentity(identity, object : StatusListener() {
                    override fun onSuccess() {
                        TwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Members.removeByIdentity) => onSuccess")
                        result.success(Mapper.membersToMap(channel.members, channel))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Members.removeByIdentity) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MembersMethods.removeByIdentity (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }
}

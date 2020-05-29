package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.Channel
import com.twilio.chat.ErrorInfo
import com.twilio.chat.StatusListener
import com.twilio.chat.User
import com.twilio.chat.UserDescriptor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object MemberMethods {
    fun getChannel(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
            ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MemberMethods.getChannel => onSuccess")
                result.success(Mapper.channelToMap(channel))
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MemberMethods.getChannel => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun getUserDescriptor(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val memberSid = call.argument<String>("memberSid")
                ?: return result.error("ERROR", "Missing 'memberSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("MemberMethods.getUserDescriptor => onSuccess")
                    val member = channel.members.membersList.find { it.sid == memberSid }
                    if (member != null) {
                        member.getUserDescriptor(object : CallbackListener<UserDescriptor>() {
                            override fun onSuccess(userDescriptor: UserDescriptor) {
                                TwilioProgrammableChatPlugin.debug("MemberMethods.getUserDescriptor (Member.getUserDescriptor) => onSuccess")
                                result.success(Mapper.userDescriptorToMap(userDescriptor))
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                TwilioProgrammableChatPlugin.debug("ChannelsMethods.getUserDescriptor => getUserDescriptor onError: $errorInfo")
                                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                            }
                        })
                    } else {
                        return result.error("ERROR", "No member found on channel '$channelSid' with sid '$memberSid'", null)
                    }
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelsMethods.getUserDescriptor => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getAndSubscribeUser(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val memberSid = call.argument<String>("memberSid")
                ?: return result.error("ERROR", "Missing 'memberSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("MemberMethods.getAndSubscribeUser => onSuccess")
                    val member = channel.members.membersList.find { it.sid == memberSid }
                    if (member != null) {
                        member.getAndSubscribeUser(object : CallbackListener<User>() {
                            override fun onSuccess(user: User) {
                                TwilioProgrammableChatPlugin.debug("MemberMethods.getAndSubscribeUser (Member.getAndSubscribeUser) => onSuccess")
                                result.success(Mapper.userToMap(user))
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                TwilioProgrammableChatPlugin.debug("ChannelsMethods.getAndSubscribeUser => getAndSubscribeUser onError: $errorInfo")
                                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                            }
                        })
                    } else {
                        return result.error("ERROR", "No member found on channel '$channelSid' with sid '$memberSid'", null)
                    }
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelsMethods.getAndSubscribeUser => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun setAttributes(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val memberSid = call.argument<String>("memberSid")
                ?: return result.error("ERROR", "Missing 'memberSid'", null)

        // Not erroring out because a nullable attributes is allowed to reset the Channel attributes.
        val attributes = call.argument<Map<String, Any>>("attributes")

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("MemberMethods.setAttributes => onSuccess")
                    val member = channel.members.membersList.find { it.sid == memberSid }
                    if (member != null) {
                        member.setAttributes(Mapper.mapToAttributes(attributes), object : StatusListener() {
                            override fun onSuccess() {
                                TwilioProgrammableChatPlugin.debug("MemberMethods.setAttributes  (Channel.setAttributes) => onSuccess")
                                try {
                                    result.success(Mapper.attributesToMap(member.attributes))
                                } catch (err: JSONException) {
                                    return result.error("JSONException", err.message, null)
                                }
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                TwilioProgrammableChatPlugin.debug("MemberMethods.setAttributes  (Channel.setAttributes) => onError: $errorInfo")
                                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                            }
                        })
                    } else {
                        return result.error("ERROR", "No member found on channel '$channelSid' with sid '$memberSid'", null)
                    }
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("MemberMethods.setAttributes => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }
}

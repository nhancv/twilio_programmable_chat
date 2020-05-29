package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.Channel
import com.twilio.chat.ErrorInfo
import com.twilio.chat.Message
import com.twilio.chat.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object MessageMethods {
    fun getChannel(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessageMethods.getChannel => onSuccess")
                result.success(Mapper.channelToMap(channel))
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessageMethods.getChannel => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun updateMessageBody(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val messageIndex = call.argument<Long>("messageIndex")
                ?: return result.error("ERROR", "Missing 'messageIndex'", null)

        val body = call.argument<String>("body")
                ?: return result.error("ERROR", "Missing 'body'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Channels.getChannel) => onSuccess")

                channel.messages.getMessageByIndex(messageIndex, object : CallbackListener<Message>() {
                    override fun onSuccess(message: Message) {
                        TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Messages.getMessageByIndex) => onSuccess")

                        message.updateMessageBody(body, object : StatusListener() {
                            override fun onSuccess() {
                                TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Message.updateMessageBody) => onSuccess")
                                result.success(message.messageBody)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Message.updateMessageBody) => onError: $errorInfo")
                                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                            }
                        })
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Messages.getMessageByIndex) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun setAttributes(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val messageIndex = call.argument<Long>("messageIndex")
                ?: return result.error("ERROR", "Missing 'messageIndex'", null)

        // Not erroring out because a nullable attributes is allowed to reset the Channel attributes.
        val attributes = call.argument<Map<String, Any>>("attributes")

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes => onSuccess")

                    channel.messages.getMessageByIndex(messageIndex, object : CallbackListener<Message>() {
                        override fun onSuccess(message: Message) {
                            TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Messages.getMessageByIndex) => onSuccess")
                            message.setAttributes(Mapper.mapToAttributes(attributes), object : StatusListener() {
                                override fun onSuccess() {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes  (Channel.setAttributes) => onSuccess")
                                    try {
                                        result.success(Mapper.attributesToMap(message.attributes))
                                    } catch (err: JSONException) {
                                        return result.error("JSONException", err.message, null)
                                    }
                                }

                                override fun onError(errorInfo: ErrorInfo) {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes  (Channel.setAttributes) => onError: $errorInfo")
                                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                                }
                            })
                            try {
                                result.success(Mapper.attributesToMap(message.attributes))
                            } catch (err: JSONException) {
                                return result.error("JSONException", err.message, null)
                            }
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("MessageMethods.updateMessageBody (Messages.getMessageByIndex) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("MessageMethods.setAttributes => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }
}

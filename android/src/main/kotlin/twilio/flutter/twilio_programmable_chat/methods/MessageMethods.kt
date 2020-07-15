package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.Channel
import com.twilio.chat.ErrorInfo
import com.twilio.chat.Message
import com.twilio.chat.ProgressListener
import com.twilio.chat.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
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

        val messageIndex = call.argument<Int>("messageIndex")?.toLong()
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

        val messageIndex = call.argument<Int>("messageIndex")?.toLong()
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

    fun getMedia(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val messageIndex = call.argument<Int>("messageIndex")?.toLong()
                ?: return result.error("ERROR", "Missing 'messageIndex'", null)

        val path = call.argument<String>("filePath")
                ?: return result.error("ERROR", "Missing 'filePath'", null)

        val file = File(path)
        if (file.exists() && file.length() > 0) {
            result.success(true)
        } else {
            TwilioProgrammableChatPlugin.debug("Downloading media for message $messageIndex to path: $path")
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia => onSuccess")
                    channel.messages.getMessageByIndex(messageIndex, object : CallbackListener<Message>() {
                        override fun onSuccess(message: Message) {
                            TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia (Messages.getMessageByIndex) => onSuccess")
                            message.media.download(file.outputStream(), object : StatusListener() {
                                override fun onSuccess() {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia (Message.Media.download) => onSuccess")
                                    result.success(true)
                                }

                                override fun onError(errorInfo: ErrorInfo) {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia (Message.Media.download) => onError: $errorInfo")
                                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                                }
                            }, object : ProgressListener() {
                                override fun onStarted() {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia (Message.Media.download) => onStarted")
                                }

                                override fun onProgress(bytes: Long) {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia (Message.Media.download) => onProgress: $bytes")
                                }

                                override fun onCompleted(mediaSid: String?) {
                                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia (Message.Media.download) => onCompleted: $mediaSid")
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
                    TwilioProgrammableChatPlugin.debug("MessageMethods.getMedia => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        }
    }
}

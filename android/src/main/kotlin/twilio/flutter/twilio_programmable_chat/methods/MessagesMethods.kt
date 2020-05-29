package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.Channel
import com.twilio.chat.ErrorInfo
import com.twilio.chat.Message
import com.twilio.chat.ProgressListener
import com.twilio.chat.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object MessagesMethods {
    fun sendMessage(call: MethodCall, result: MethodChannel.Result) {
        val options = call.argument<Map<String, Any>>("options")
                ?: return result.error("ERROR", "Missing 'options'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val messageOptions = Message.options()
        if (options["body"] != null) {
            messageOptions.withBody(options["body"] as String)
        }
        if (options["attributes"] != null) {
            messageOptions.withAttributes(Mapper.mapToAttributes(options["attributes"] as Map<String, Any>?))
        }
        if (options["input"] != null) {
            val input = options["input"] as String
            val mimeType = options["mimeType"] as String?
                    ?: return result.error("ERROR", "Missing 'mimeType' in MessageOptions", null)

            messageOptions.withMedia(FileInputStream(input), mimeType)
            if (options["filename"] != null) {
                messageOptions.withMediaFileName(options["filename"] as String)
            }

            if (options["mediaProgressListenerId"] != null) {
                messageOptions.withMediaProgressListener(object : ProgressListener() {
                    override fun onStarted() {
                        TwilioProgrammableChatPlugin.mediaProgresSink?.success({
                            "mediaProgressListenerId" to options["mediaProgressListenerId"]
                            "name" to "started"
                        })
                    }

                    override fun onProgress(bytes: Long) {
                        TwilioProgrammableChatPlugin.mediaProgresSink?.success({
                            "mediaProgressListenerId" to options["mediaProgressListenerId"]
                            "name" to "progress"
                            "data" to bytes
                        })
                    }

                    override fun onCompleted(mediaSid: String) {
                        TwilioProgrammableChatPlugin.mediaProgresSink?.success({
                            "mediaProgressListenerId" to options["mediaProgressListenerId"]
                            "name" to "completed"
                            "data" to mediaSid
                        })
                    }
                })
            }
        }

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Channels.getChannel) => onSuccess")

                channel.messages.sendMessage(messageOptions, object : CallbackListener<Message>() {
                    override fun onSuccess(message: Message) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Message.sendMessage) => onSuccess")
                        result.success(Mapper.messageToMap(message))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Message.sendMessage) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun removeMessage(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)
        val messageIndex = call.argument<Long>("messageIndex")
                ?: return result.error("ERROR", "Missing 'messageIndex'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Channels.getChannel) => onSuccess")

                channel.messages.getMessageByIndex(messageIndex, object : CallbackListener<Message>() {
                    override fun onSuccess(message: Message) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.getMessageByIndex) => onSuccess")

                        channel.messages.removeMessage(message, object : StatusListener() {
                            override fun onSuccess() {
                                TwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.removeMessage) => onSuccess")
                                result.success(null)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                TwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.removeMessage) => onError: $errorInfo")
                                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                            }
                        })
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.removeMessage (Messages.getMessageByIndex) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.sendMessage (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun getMessagesBefore(call: MethodCall, result: MethodChannel.Result) {
        val index = call.argument<Long>("index")
                ?: return result.error("ERROR", "Missing 'index'", null)
        val count = call.argument<Int>("count")
                ?: return result.error("ERROR", "Missing 'count'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesBefore (Channels.getChannel) => onSuccess")

                channel.messages.getMessagesBefore(index, count, object : CallbackListener<List<Message>>() {
                    override fun onSuccess(messages: List<Message>) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesBefore (Message.getMessagesBefore) => onSuccess")
                        val messagesListMap = messages?.map { Mapper.messageToMap(it) }
                        result.success(messagesListMap)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesBefore (Message.getMessagesBefore) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesBefore (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun getMessagesAfter(call: MethodCall, result: MethodChannel.Result) {
        val index = call.argument<Int>("index")?.toLong()
                ?: return result.error("ERROR", "Missing 'index'", null)
        val count = call.argument<Int>("count")
                ?: return result.error("ERROR", "Missing 'count'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesAfter (Channels.getChannel) => onSuccess")

                channel.messages.getMessagesAfter(index, count, object : CallbackListener<List<Message>>() {
                    override fun onSuccess(messages: List<Message>) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesAfter (Message.getMessagesAfter) => onSuccess")
                        val messagesListMap = messages?.map { Mapper.messageToMap(it) }
                        result.success(messagesListMap)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesAfter (Message.getMessagesAfter) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessagesAfter (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun getLastMessages(call: MethodCall, result: MethodChannel.Result) {
        val count = call.argument<Int>("count")
                ?: return result.error("ERROR", "Missing 'count'", null)
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getLastMessages (Channels.getChannel) => onSuccess")

                channel.messages.getLastMessages(count, object : CallbackListener<List<Message>>() {
                    override fun onSuccess(messages: List<Message>) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getLastMessages (Message.getLastMessages) => onSuccess")
                        val messagesListMap = messages.map { Mapper.messageToMap(it) }
                        result.success(messagesListMap)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getLastMessages (Message.getLastMessages) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getLastMessages (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun getMessageByIndex(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)
        val messageIndex = call.argument<Long>("messageIndex")
                ?: return result.error("ERROR", "Missing 'messageIndex'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessageByIndex (Channels.getChannel) => onSuccess")

                channel.messages.getMessageByIndex(messageIndex, object : CallbackListener<Message>() {
                    override fun onSuccess(message: Message) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessageByIndex (Message.getMessageByIndex) => onSuccess")
                        result.success(Mapper.messageToMap(message))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessageByIndex (Message.getMessageByIndex) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.getMessageByIndex (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun setLastConsumedMessageIndexWithResult(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)
        val lastConsumedMessageIndex = call.argument<Long>("lastConsumedMessageIndex")
                ?: return result.error("ERROR", "Missing 'lastConsumedMessageIndex'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.setLastConsumedMessageIndexWithResult (Channels.getChannel) => onSuccess")

                channel.messages.setLastConsumedMessageIndexWithResult(lastConsumedMessageIndex, object : CallbackListener<Long>() {
                    override fun onSuccess(newIndex: Long) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.setLastConsumedMessageIndexWithResult (Message.setLastConsumedMessageIndexWithResult) => onSuccess: $newIndex")
                        result.success(newIndex)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.setLastConsumedMessageIndexWithResult (Message.setLastConsumedMessageIndexWithResult) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.setLastConsumedMessageIndexWithResult (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun advanceLastConsumedMessageIndexWithResult(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)
        val lastConsumedMessageIndex = call.argument<Long>("lastConsumedMessageIndex")
                ?: return result.error("ERROR", "Missing 'lastConsumedMessageIndex'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.advanceLastConsumedMessageIndexWithResult (Channels.getChannel) => onSuccess")

                channel.messages.advanceLastConsumedMessageIndexWithResult(lastConsumedMessageIndex, object : CallbackListener<Long>() {
                    override fun onSuccess(newIndex: Long) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.advanceLastConsumedMessageIndexWithResult (Message.advanceLastConsumedMessageIndexWithResult) => onSuccess: $newIndex")
                        result.success(newIndex)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.advanceLastConsumedMessageIndexWithResult (Message.advanceLastConsumedMessageIndexWithResult) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.advanceLastConsumedMessageIndexWithResult (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun setAllMessagesConsumedWithResult(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.setAllMessagesConsumedWithResult (Channels.getChannel) => onSuccess")

                channel.messages.setAllMessagesConsumedWithResult(object : CallbackListener<Long>() {
                    override fun onSuccess(index: Long) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.setAllMessagesConsumedWithResult (Message.setAllMessagesConsumedWithResult) => onSuccess: $index")
                        result.success(index)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.setAllMessagesConsumedWithResult (Message.setAllMessagesConsumedWithResult) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.setAllMessagesConsumedWithResult (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun setNoMessagesConsumedWithResult(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
            override fun onSuccess(channel: Channel) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.setNoMessagesConsumedWithResult (Channels.getChannel) => onSuccess")

                channel.messages.setNoMessagesConsumedWithResult(object : CallbackListener<Long>() {
                    override fun onSuccess(index: Long) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.setNoMessagesConsumedWithResult (Message.setNoMessagesConsumedWithResult) => onSuccess: $index")
                        result.success(index)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioProgrammableChatPlugin.debug("MessagesMethods.setNoMessagesConsumedWithResult (Message.setNoMessagesConsumedWithResult) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("MessagesMethods.setNoMessagesConsumedWithResult (Channels.getChannel) => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }
}

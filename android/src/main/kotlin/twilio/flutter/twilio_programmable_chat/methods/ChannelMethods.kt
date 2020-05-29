package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.Channel
import com.twilio.chat.ErrorInfo
import com.twilio.chat.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object ChannelMethods {
    fun join(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.join => onSuccess")
                    channel.join(object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.join (Channel.join) => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.join (Channel.join) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.join => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun leave(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.leave => onSuccess")
                    channel.leave(object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.leave (Channel.leave) => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.leave (Channel.leave) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.leave => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun typing(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.typing => onSuccess")
                    channel.typing()
                    result.success(null)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.typing => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun declineInvitation(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation => onSuccess")
                    channel.declineInvitation(object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation (Channel.declineInvitation) => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation (Channel.declineInvitation) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.declineInvitation => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun destroy(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.destroy => onSuccess")
                    channel.destroy(object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.destroy (Channel.destroy) => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.destroy (Channel.destroy) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.destroy => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getMessagesCount(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount => onSuccess")
                    channel.getMessagesCount(object : CallbackListener<Long>() {
                        override fun onSuccess(messageCount: Long) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount (Channel.getMessagesCount) => onSuccess: $messageCount")
                            result.success(messageCount)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount (Channel.getMessagesCount) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getMessagesCount => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getUnconsumedMessagesCount(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount => onSuccess")
                    channel.getUnconsumedMessagesCount(object : CallbackListener<Long>() {
                        override fun onSuccess(unconsumedMessageCount: Long) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount (Channel.getUnconsumedMessagesCount) => onSuccess: $unconsumedMessageCount")
                            result.success(unconsumedMessageCount)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount (Channel.getUnconsumedMessagesCount) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getUnconsumedMessagesCount => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getMembersCount(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount => onSuccess")
                    channel.getMembersCount(object : CallbackListener<Long>() {
                        override fun onSuccess(membersCount: Long) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount (Channel.getMembersCount) => onSuccess: $membersCount")
                            result.success(membersCount)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount (Channel.getMembersCount)  => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getMembersCount => onError: $errorInfo")
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

        // Not erroring out because a nullable attributes is allowed to reset the Channel attributes.
        val attributes = call.argument<Map<String, Any>>("attributes")

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes => onSuccess")
                    channel.setAttributes(Mapper.mapToAttributes(attributes), object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes  (Channel.setAttributes) => onSuccess")
                            try {
                                result.success(Mapper.attributesToMap(channel.attributes))
                            } catch (err: JSONException) {
                                return result.error("JSONException", err.message, null)
                            }
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes  (Channel.setAttributes) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getFriendlyName(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getFriendlyName => onSuccess")
                    result.success(channel.friendlyName)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getFriendlyName => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun setFriendlyName(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val friendlyName = call.argument<String>("friendlyName")
                ?: return result.error("ERROR", "Missing 'friendlyName'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setFriendlyName => onSuccess")
                    channel.setFriendlyName(friendlyName, object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setFriendlyName  (Channel.setFriendlyName) => onSuccess")
                            result.success(channel.friendlyName)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setFriendlyName  (Channel.setFriendlyName) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setFriendlyName => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getNotificationLevel(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getNotificationLevel => onSuccess")
                    result.success(channel.notificationLevel.toString())
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getNotificationLevel => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun setNotificationLevel(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val notificationLevelValue = call.argument<String>("notificationLevel")
                ?: return result.error("ERROR", "Missing 'notificationLevel'", null)

        val notificationLevel = when (notificationLevelValue) {
            "DEFAULT" -> Channel.NotificationLevel.DEFAULT
            "MUTED" -> Channel.NotificationLevel.MUTED
            else -> null
        } ?: return result.error("ERROR", "Wrong value for 'notificationLevel'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setNotificationLevel => onSuccess")
                    channel.setNotificationLevel(notificationLevel, object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setNotificationLevel  (Channel.setNotificationLevel) => onSuccess")
                            result.success(channel.notificationLevel.toString())
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setNotificationLevel  (Channel.setNotificationLevel) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setAttributes => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getUniqueName(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getUniqueName => onSuccess")
                    result.success(channel.uniqueName)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.getUniqueName => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun setUniqueName(call: MethodCall, result: MethodChannel.Result) {
        val channelSid = call.argument<String>("channelSid")
                ?: return result.error("ERROR", "Missing 'channelSid'", null)

        val uniqueName = call.argument<String>("uniqueName")
                ?: return result.error("ERROR", "Missing 'uniqueName'", null)

        try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.channels?.getChannel(channelSid, object : CallbackListener<Channel>() {
                override fun onSuccess(channel: Channel) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setUniqueName => onSuccess")
                    channel.setUniqueName(uniqueName, object : StatusListener() {
                        override fun onSuccess() {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setUniqueName  (Channel.setUniqueName) => onSuccess")
                            result.success(channel.uniqueName)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioProgrammableChatPlugin.debug("ChannelMethods.setUniqueName  (Channel.setUniqueName) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("ChannelMethods.setUniqueName => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }
}

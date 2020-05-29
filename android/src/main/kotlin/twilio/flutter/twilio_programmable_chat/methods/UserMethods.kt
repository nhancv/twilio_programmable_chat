package twilio.flutter.twilio_programmable_chat.methods

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object UserMethods {
    fun unsubscribe(call: MethodCall, result: MethodChannel.Result) {
        val identity = call.argument<String>("identity")
                ?: return result.error("ERROR", "Missing 'identity'", null)

        try {
            val subscribedUser = TwilioProgrammableChatPlugin.chatListener.chatClient?.users?.subscribedUsers?.find { it.identity == identity }

            if (subscribedUser != null) {
                subscribedUser.unsubscribe()
            } else {
                return result.error("ERROR", "No subscribed user found with the identity '$identity'", null)
            }
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }
}

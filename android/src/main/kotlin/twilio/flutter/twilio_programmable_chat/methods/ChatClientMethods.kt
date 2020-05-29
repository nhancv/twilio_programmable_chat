package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.ErrorInfo
import com.twilio.chat.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object ChatClientMethods {
    fun updateToken(call: MethodCall, result: MethodChannel.Result) {
        val token = call.argument<String>("token")
                ?: return result.error("ERROR", "Missing 'token'", null)

        TwilioProgrammableChatPlugin.chatListener.chatClient?.updateToken(token, object : StatusListener() {
            override fun onSuccess() {
                TwilioProgrammableChatPlugin.debug("ChatClientMethods.updateToken => onSuccess")
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioProgrammableChatPlugin.debug("ChatClientMethods.updateToken => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun shutdown(call: MethodCall, result: MethodChannel.Result) {
        return try {
            TwilioProgrammableChatPlugin.chatListener.chatClient?.shutdown()
            result.success(null)
        } catch (err: Exception) {
            result.error("ERROR", err.message, null)
        }
    }
}

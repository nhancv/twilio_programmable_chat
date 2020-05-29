package twilio.flutter.twilio_programmable_chat.methods

import com.twilio.chat.CallbackListener
import com.twilio.chat.ErrorInfo
import com.twilio.chat.Paginator
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_programmable_chat.Mapper
import twilio.flutter.twilio_programmable_chat.PaginatorManager
import twilio.flutter.twilio_programmable_chat.TwilioProgrammableChatPlugin

object PaginatorMethods {
    fun requestNextPage(call: MethodCall, result: MethodChannel.Result) {
        val pageId = call.argument<String>("pageId")
                ?: return result.error("ERROR", "Missing 'pageId'", null)
        val itemType = call.argument<String>("itemType")
                ?: return result.error("ERROR", "Missing 'itemType'", null)

        val paginator = PaginatorManager.getPaginator<Any>(pageId)
        try {
            paginator.requestNextPage(object : CallbackListener<Paginator<Any>>() {
                override fun onSuccess(paginator: Paginator<Any>) {
                    TwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextPage => onSuccess")
                    val pageId = PaginatorManager.setPaginator(paginator)
                    result.success(Mapper.paginatorToMap(pageId, paginator, itemType))
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextPage => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalStateException) {
            return result.error("IllegalStateException", err.message, null)
        }
    }
}

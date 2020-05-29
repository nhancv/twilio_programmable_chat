package twilio.flutter.twilio_programmable_chat

import com.twilio.chat.Paginator
import java.util.UUID

object PaginatorManager {
    private val paginators: HashMap<String, Paginator<Any>> = hashMapOf()

    @Suppress("UNCHECKED_CAST")
    fun <T> setPaginator(paginator: Paginator<T>): String {
        val pageId = UUID.randomUUID().toString()
        paginators[pageId] = paginator as Paginator<Any>
        return pageId
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> getPaginator(pageId: String): Paginator<T> {
        if (!paginators.containsKey(pageId)) {
            throw Exception("Could not find paginator with pageId '$pageId'")
        }
        return paginators[pageId] as Paginator<T>
    }
}

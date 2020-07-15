import Foundation
import TwilioChatClient

public class PaginatorManager {
    internal static var paginators = [String: Any]()

    public static func setPaginator(_ paginator: Any) -> String {
        let pageId = UUID.init().uuidString
        paginators[pageId] = paginator
        return pageId
    }

    public static func getPaginator<T>(_ pageId: String) throws -> T {
        if !paginators.keys.contains(pageId) {
            throw PaginatorManagerError("Could not find paginator with pageId '\(pageId)'")
        } else {
            if let paginator = paginators[pageId] as? T {
                return paginator
            } else {
                throw PaginatorManagerError("Error converting '\(String(describing: paginators[pageId]))' to \(T.self)")
            }
        }
    }
}

struct PaginatorManagerError: Error {
    let error: String

    init(_ errorString: String) {
        self.error = errorString
    }
}

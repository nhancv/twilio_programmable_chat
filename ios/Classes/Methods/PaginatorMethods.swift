import Flutter
import Foundation
import TwilioChatClient

public class PaginatorMethods {
    public static func requestNextPage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let pageId = arguments["pageId"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'pageId' parameter", details: nil))
        }

        guard let itemType = arguments["itemType"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'itemType' parameter", details: nil))
        }

        if itemType == "userDescriptor" {
            requestNextUserDescriptorPage(pageId, flutterResult: result)
        } else if itemType == "channelDescriptor" {
            requestNextChannelDescriptorPage(pageId, flutterResult: result)
        } else {
            result(FlutterError(code: "ERROR", message: "Could not parse itemType: \(itemType)", details: nil))
        }
    }

    static func requestNextUserDescriptorPage(_ pageId: String, flutterResult: @escaping FlutterResult) {
        do {
            let paginator: TCHUserDescriptorPaginator = try PaginatorManager.getPaginator(pageId)
            paginator.requestNextPage { (result: TCHResult, paginator: TCHUserDescriptorPaginator?) in
                if result.isSuccessful(), let paginator = paginator {
                    SwiftTwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextUserDescriptorPage (Paginator.requestNextPage) => onSuccess")
                    let pageId = PaginatorManager.setPaginator(paginator)
                    flutterResult(Mapper.userDescriptorsToDict(pageId, paginator))
                } else {
                    SwiftTwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextUserDescriptorPage (Paginator.requestNextPage) => onError: \(String(describing: result.error))")
                    flutterResult(FlutterError(code: "ERROR", message: "Error requesting next page for user descriptor paginator (pageId: \(pageId))", details: nil))
                }
            }
        } catch let error {
            SwiftTwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextUserDescriptorPage (Paginator.requestNextPage) => onThrow: \(String(describing: error))")
            flutterResult(FlutterError(code: "ERROR", message: "Error requesting next page for user descriptor paginator (pageId: \(pageId))", details: error))
        }
    }

    static func requestNextChannelDescriptorPage(_ pageId: String, flutterResult: @escaping FlutterResult) {
        do {
            let paginator: TCHChannelDescriptorPaginator = try PaginatorManager.getPaginator(pageId)
            paginator.requestNextPage { (result: TCHResult, paginator: TCHChannelDescriptorPaginator?) in
                if result.isSuccessful(), let paginator = paginator {
                    SwiftTwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextChannelDescriptorPage (Paginator.requestNextPage) => onSuccess")
                    let pageId = PaginatorManager.setPaginator(paginator)
                    flutterResult(Mapper.channelDescriptorsToDict(pageId, paginator))
                } else {
                    SwiftTwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextChannelDescriptorPage (Paginator.requestNextPage) => onError: \(String(describing: result.error))")
                    flutterResult(FlutterError(code: "ERROR", message: "Error requesting next page for channel descriptor paginator (pageId: \(pageId))", details: nil))
                }
            }
        } catch let error {
            SwiftTwilioProgrammableChatPlugin.debug("PaginatorMethods.requestNextChannelDescriptorPage (Paginator.requestNextPage) => onThrow: \(String(describing: error))")
            flutterResult(FlutterError(code: "ERROR", message: "Error requesting next page for channel descriptor paginator (pageId: \(pageId))", details: error))
        }
    }
}

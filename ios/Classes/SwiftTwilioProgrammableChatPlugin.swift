import Flutter
import UIKit
import TwilioChatClient

public class SwiftTwilioProgrammableChatPlugin: NSObject, FlutterPlugin {
    public static var loggingSink: FlutterEventSink?

    public static var nativeDebug = false

    public static var messenger: FlutterBinaryMessenger?

    public static var chatListener: ChatListener?

    public static var channelChannels: [String: FlutterEventChannel] = [:]

    public static var channelListeners: [String: ChannelListener] = [:]

    public static var mediaProgressSink: FlutterEventSink?

    public static func debug(_ msg: String) {
        if SwiftTwilioProgrammableChatPlugin.nativeDebug {
            NSLog(msg)
            guard let loggingSink = loggingSink else {
                return
            }
            loggingSink(msg)
        }
    }

    private var methodChannel: FlutterMethodChannel?

    private var chatChannel: FlutterEventChannel?

    private var mediaProgressChannel: FlutterEventChannel?

    private var loggingChannel: FlutterEventChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftTwilioProgrammableChatPlugin()
        instance.onRegister(registrar)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }

    public func onRegister(_ registrar: FlutterPluginRegistrar) {
        SwiftTwilioProgrammableChatPlugin.messenger = registrar.messenger()
        let pluginHandler = PluginHandler()
        methodChannel = FlutterMethodChannel(name: "twilio_programmable_chat", binaryMessenger: registrar.messenger())
        methodChannel?.setMethodCallHandler(pluginHandler.handle)

        chatChannel = FlutterEventChannel(name: "twilio_programmable_chat/room", binaryMessenger: registrar.messenger())
        chatChannel?.setStreamHandler(ChatStreamHandler())

        mediaProgressChannel = FlutterEventChannel(
            name: "twilio_programmable_chat/media_progress", binaryMessenger: registrar.messenger())
        mediaProgressChannel?.setStreamHandler(MediaProgressStreamHandler())

        loggingChannel = FlutterEventChannel(
            name: "twilio_programmable_chat/logging", binaryMessenger: registrar.messenger())
        loggingChannel?.setStreamHandler(LoggingStreamHandler())
        registrar.addApplicationDelegate(self)
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        SwiftTwilioProgrammableChatPlugin.debug("PluginAppDelegate.applicationWillEnterForeground")
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        SwiftTwilioProgrammableChatPlugin.debug("PluginAppDelegate.applicationDidEnterBackground")
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        SwiftTwilioProgrammableChatPlugin.debug("PluginAppDelegate.applicationWillResignActive")
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        SwiftTwilioProgrammableChatPlugin.debug("PluginAppDelegate.applicationDidBecomeActive")
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        SwiftTwilioProgrammableChatPlugin.debug("PluginAppDelegate.applicationWillTerminate")
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "PluginAppDelegate.didRegisterForRemoteNotificationsWithDeviceToken => onSuccess")
        //        SwiftTwilioProgrammableChatPlugin.apnsToken = deviceToken
    }

    class ChatStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            guard let chatListener = SwiftTwilioProgrammableChatPlugin.chatListener else { return nil }
            SwiftTwilioProgrammableChatPlugin.debug("ChatStreamHandler.onListen => Chat eventChannel attached")
            chatListener.events = events
            chatListener.chatClient?.delegate = chatListener
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("RoomStreamHandler.onCancel => Room eventChannel detached")
            guard let chatListener = SwiftTwilioProgrammableChatPlugin.chatListener else { return nil }
            chatListener.events = nil
            return nil
        }
    }

    class MediaProgressStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            debug("MediaProgressStreamHandler.onListen => MediaProgress eventChannel attached")
            SwiftTwilioProgrammableChatPlugin.mediaProgressSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            debug("MediaProgressStreamHandler.onCancel => MediaProgress eventChannel detached")
            SwiftTwilioProgrammableChatPlugin.mediaProgressSink = nil
            return nil
        }
    }

    class LoggingStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("LoggingStreamHandler.onListen => Logging eventChannel attached")
            SwiftTwilioProgrammableChatPlugin.loggingSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("LoggingStreamHandler.onCancel => Logging eventChannel detached")
            SwiftTwilioProgrammableChatPlugin.loggingSink = nil
            return nil
        }
    }
}

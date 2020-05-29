part of twilio_programmable_chat;

//#region ChatClient events
class ChannelUpdatedEvent {
  final Channel channel;

  final ChannelUpdateReason reason;

  ChannelUpdatedEvent(this.channel, this.reason)
      : assert(channel != null),
        assert(reason != null);
}

class UserUpdatedEvent {
  final User user;

  final UserUpdateReason reason;

  UserUpdatedEvent(this.user, this.reason)
      : assert(user != null),
        assert(reason != null);
}

class NewMessageNotificationEvent {
  final String channelSid;

  final String messageSid;

  final int messageIndex;

  NewMessageNotificationEvent(this.channelSid, this.messageSid, this.messageIndex)
      : assert(channelSid != null),
        assert(messageSid != null),
        assert(messageIndex != null);
}
//#endregion

/// Chat client - main entry point for the Chat SDK.
class ChatClient {
  /// Stream for the native chat events.
  StreamSubscription<dynamic> _chatStream;

  //#region Private API properties
  Properties _properties;

  Channels _channels;

  ConnectionState _connectionState;

  final String _myIdentity;

  Users _users;

  bool _isReachabilityEnabled;
  //#endregion

  //#region Public API properties
  /// Get properties for current client.
  Properties get properties {
    return _properties;
  }

  /// [Channels] available to the current client.
  Channels get channels {
    return _channels;
  }

  /// Current transport state
  ConnectionState get connectionState {
    return _connectionState;
  }

  /// Get user identity for the current user.
  String get myIdentity {
    return _myIdentity;
  }

  /// Get [Users] interface.
  Users get users {
    return _users;
  }

  /// Get reachability service status.
  bool get isReachabilityEnabled {
    return _isReachabilityEnabled;
  }
  //#endregion

  //#region Channel events
  final StreamController<Channel> _onChannelAddedCtrl = StreamController<Channel>.broadcast();

  /// Called when the current user has a channel added to their channel list, channel status is not specified.
  Stream<Channel> onChannelAdded;

  final StreamController<Channel> _onChannelDeletedCtrl = StreamController<Channel>.broadcast();

  /// Called when one of the channel of the current user is deleted.
  Stream<Channel> onChannelDeleted;

  final StreamController<Channel> _onChannelInvitedCtrl = StreamController<Channel>.broadcast();

  /// Called when the current user was invited to a channel, channel status is [ChannelStatus.INVITED].
  Stream<Channel> onChannelInvited;

  final StreamController<Channel> _onChannelJoinedCtrl = StreamController<Channel>.broadcast();

  /// Called when the current user either joined or was added into a channel, channel status is [ChannelStatus.JOINED].
  Stream<Channel> onChannelJoined;

  final StreamController<Channel> _onChannelSynchronizationChangeCtrl = StreamController<Channel>.broadcast();

  /// Called when channel synchronization status changed.
  ///
  /// Use [Channel.synchronizationStatus] to obtain new channel status.
  Stream<Channel> onChannelSynchronizationChange;

  final StreamController<ChannelUpdatedEvent> _onChannelUpdatedCtrl = StreamController<ChannelUpdatedEvent>.broadcast();

  /// Called when the channel is updated.
  ///
  /// [Channel] synchronization updates are delivered via different callback.
  Stream<ChannelUpdatedEvent> onChannelUpdated;
  //#endregion

  //#region ChatClient events
  final StreamController<ChatClientSynchronizationStatus> _onClientSynchronizationCtrl = StreamController<ChatClientSynchronizationStatus>.broadcast();

  /// Called when client synchronization status changes.
  Stream<ChatClientSynchronizationStatus> onClientSynchronization;

  final StreamController<ConnectionState> _onConnectionStateCtrl = StreamController<ConnectionState>.broadcast();

  /// Called when client connnection state has changed.
  Stream<ConnectionState> onConnectionState;

  final StreamController<ErrorInfo> _onErrorCtrl = StreamController<ErrorInfo>.broadcast();

  /// Called when an error condition occurs.
  Stream<ErrorInfo> onError;
  //#endregion

  //#region Notification events
  final StreamController<String> _onAddedToChannelNotificationCtrl = StreamController<String>.broadcast();

  /// Called when client receives a push notification for added to channel event.
  Stream<String> onAddedToChannelNotification;

  final StreamController<String> _onInvitedToChannelNotificationCtrl = StreamController<String>.broadcast();

  /// Called when client receives a push notification for invited to channel event.
  Stream<String> onInvitedToChannelNotification;

  final StreamController<NewMessageNotificationEvent> _onNewMessageNotificationCtrl = StreamController<NewMessageNotificationEvent>.broadcast();

  /// Called when client receives a push notification for new message.
  Stream<NewMessageNotificationEvent> onNewMessageNotification;

  final StreamController<ErrorInfo> _onNotificationFailedCtrl = StreamController<ErrorInfo>.broadcast();

  /// Called when registering for push notifications fails.
  Stream<ErrorInfo> onNotificationFailed;

  final StreamController<String> _onRemovedFromChannelNotificationCtrl = StreamController<String>.broadcast();

  /// Called when client receives a push notification for removed from channel event.
  Stream<String> onRemovedFromChannelNotification;
  //#endregion

  //#region Token events
  final StreamController<void> _onTokenAboutToExpireCtrl = StreamController<void>.broadcast();

  /// Called when token is about to expire soon.
  ///
  /// In response, [ChatClient] should generate a new token and call [ChatClient.updateToken] as soon as possible.
  Stream<void> onTokenAboutToExpire;

  final StreamController<void> _onTokenExpiredCtrl = StreamController<void>.broadcast();

  /// Called when token has expired.
  ///
  /// In response, [ChatClient] should generate a new token and call [ChatClient.updateToken] as soon as possible.
  Stream<void> onTokenExpired;
  //#endregion

  //#region User events
  final StreamController<User> _onUserSubscribedCtrl = StreamController<User>.broadcast();

  /// Called when a user is subscribed to and will receive realtime state updates.
  Stream<User> onUserSubscribed;

  final StreamController<User> _onUserUnsubscribedCtrl = StreamController<User>.broadcast();

  /// Called when a user is unsubscribed from and will not receive realtime state updates anymore.
  Stream<User> onUserUnsubscribed;

  final StreamController<UserUpdatedEvent> _onUserUpdatedCtrl = StreamController<UserUpdatedEvent>.broadcast();

  /// Called when user info is updated for currently loaded users.
  Stream<UserUpdatedEvent> onUserUpdated;
  //#endregion

  ChatClient(this._myIdentity) : assert(_myIdentity != null) {
    onChannelAdded = _onChannelAddedCtrl.stream;
    onChannelDeleted = _onChannelDeletedCtrl.stream;
    onChannelInvited = _onChannelInvitedCtrl.stream;
    onChannelJoined = _onChannelJoinedCtrl.stream;
    onChannelSynchronizationChange = _onChannelSynchronizationChangeCtrl.stream;
    onChannelUpdated = _onChannelUpdatedCtrl.stream;
    onClientSynchronization = _onClientSynchronizationCtrl.stream;
    onConnectionState = _onConnectionStateCtrl.stream;
    onError = _onErrorCtrl.stream;
    onAddedToChannelNotification = _onAddedToChannelNotificationCtrl.stream;
    onInvitedToChannelNotification = _onInvitedToChannelNotificationCtrl.stream;
    onNewMessageNotification = _onNewMessageNotificationCtrl.stream;
    onNotificationFailed = _onNotificationFailedCtrl.stream;
    onRemovedFromChannelNotification = _onRemovedFromChannelNotificationCtrl.stream;
    onTokenAboutToExpire = _onTokenAboutToExpireCtrl.stream;
    onTokenExpired = _onTokenExpiredCtrl.stream;
    onUserSubscribed = _onUserSubscribedCtrl.stream;
    onUserUnsubscribed = _onUserUnsubscribedCtrl.stream;
    onUserUpdated = _onUserUpdatedCtrl.stream;

    _chatStream = TwilioProgrammableChat._chatChannel.receiveBroadcastStream(0).listen(_parseEvents);
  }

  /// Construct from a map.
  factory ChatClient._fromMap(Map<String, dynamic> map) {
    var chatClient = ChatClient(map['myIdentity']);
    chatClient._updateFromMap(map);
    return chatClient;
  }

  //#region Public API methods
  /// Method to update the authentication token for this client.
  Future<void> updateToken(String token) async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('ChatClient#updateToken', <String, Object>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Cleanly shuts down the messaging client when you are done with it.
  ///
  /// It will dispose() the client after shutdown, so it could not be reused.
  Future<void> shutdown() async {
    try {
      await _chatStream.cancel();
      return await TwilioProgrammableChat._methodChannel.invokeMethod('ChatClient#shutdown', null);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _connectionState = EnumToString.fromString(ConnectionState.values, map['connectionState']);
    _isReachabilityEnabled = map['isReachabilityEnabled'];

    if (map['properties'] != null) {
      final propertiesMap = Map<String, dynamic>.from(map['properties']);
      _properties ??= Properties._fromMap(propertiesMap);
      _properties._updateFromMap(propertiesMap);
    }

    if (map['channels'] != null) {
      final channelsMap = Map<String, dynamic>.from(map['channels']);
      _channels ??= Channels._fromMap(channelsMap);
      _channels._updateFromMap(channelsMap);
    }

    if (map['users'] != null) {
      final usersMap = Map<String, dynamic>.from(map['users']);
      _users ??= Users._fromMap(usersMap);
      _users._updateFromMap(usersMap);
    }
  }

  /// Parse native chat client events to the right event streams.
  void _parseEvents(dynamic event) {
    final String eventName = event['name'];
    TwilioProgrammableChat._log("ChatClient => Event '$eventName' => ${event["data"]}, error: ${event["error"]}");
    final data = Map<String, dynamic>.from(event['data']);

    if (data['chatClient'] != null) {
      final chatClientMap = Map<String, dynamic>.from(data['chatClient']);
      _updateFromMap(chatClientMap);
    }

    ErrorInfo exception;
    if (event['error'] != null) {
      final errorMap = Map<String, dynamic>.from(event['error'] as Map<dynamic, dynamic>);
      exception = ErrorInfo(errorMap['code'] as int, errorMap['message'], errorMap['status'] as int);
    }

    Channel channel;
    if (data['channel'] != null) {
      final channelMap = Map<String, dynamic>.from(data['channel'] as Map<dynamic, dynamic>);
      // TODO(WLFN): should we cache this so we can just use references?
      channel = Channel._fromMap(channelMap);
    }

    User user;
    if (data['user'] != null) {
      final userMap = Map<String, dynamic>.from(data['user'] as Map<dynamic, dynamic>);
      // TODO(WLFN): should we cache this so we can just use references?
      user = User._fromMap(userMap);
    }

    var channelSid = data['channelSid'] as String;

    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap = Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      switch (reasonMap['type']) {
        case 'channel':
          reason = EnumToString.fromString(ChannelUpdateReason.values, reasonMap['value']);
          break;
        case 'user':
          reason = EnumToString.fromString(ChannelUpdateReason.values, reasonMap['value']);
          break;
      }
    }

    switch (eventName) {
      case 'addedToChannelNotification':
        assert(channelSid != null);
        _onAddedToChannelNotificationCtrl.add(channelSid);
        break;
      case 'channelAdded':
        assert(channel != null);
        _onChannelAddedCtrl.add(channel);
        break;
      case 'channelDeleted':
        assert(channel != null);
        _onChannelDeletedCtrl.add(channel);
        break;
      case 'channelInvited':
        assert(channel != null);
        _onChannelInvitedCtrl.add(channel);
        break;
      case 'channelJoined':
        assert(channel != null);
        _onChannelJoinedCtrl.add(channel);
        break;
      case 'channelSynchronizationChange':
        assert(channel != null);
        _onChannelSynchronizationChangeCtrl.add(channel);
        break;
      case 'channelUpdated':
        assert(channel != null);
        assert(reason != null);
        _onChannelUpdatedCtrl.add(ChannelUpdatedEvent(channel, reason));
        break;
      case 'clientSynchronization':
        var synchronizationStatus = EnumToString.fromString(ChatClientSynchronizationStatus.values, data['synchronizationStatus']);
        assert(synchronizationStatus != null);
        _onClientSynchronizationCtrl.add(synchronizationStatus);
        break;
      case 'connectionStateChange':
        var connectionState = EnumToString.fromString(ConnectionState.values, data['connectionState']);
        assert(connectionState != null);
        _connectionState = connectionState;
        _onConnectionStateCtrl.add(connectionState);
        break;
      case 'error':
        assert(exception != null);
        _onErrorCtrl.add(exception);
        break;
      case 'invitedToChannelNotification':
        assert(channelSid != null);
        _onInvitedToChannelNotificationCtrl.add(channelSid);
        break;
      case 'newMessageNotification':
        var messageSid = data['messageSid'] as String;
        var messageIndex = data['messageIndex'] as int;
        assert(channelSid != null);
        assert(messageSid != null);
        assert(messageIndex != null);
        _onNewMessageNotificationCtrl.add(NewMessageNotificationEvent(channelSid, messageSid, messageIndex));
        break;
      case 'notificationFailed':
        assert(exception != null);
        _onNotificationFailedCtrl.add(exception);
        break;
      case 'removedFromChannelNotification':
        assert(channelSid != null);
        _onRemovedFromChannelNotificationCtrl.add(channelSid);
        break;
      case 'tokenAboutToExpire':
        _onTokenAboutToExpireCtrl.add(null);
        break;
      case 'tokenExpired':
        _onTokenExpiredCtrl.add(null);
        break;
      case 'userSubscribed':
        assert(user != null);
        _onUserSubscribedCtrl.add(user);
        break;
      case 'userUnsubscribed':
        assert(user != null);
        _onUserUnsubscribedCtrl.add(user);
        break;
      case 'userUpdated':
        assert(user != null);
        assert(reason != null);
        _onUserUpdatedCtrl.add(UserUpdatedEvent(user, reason));
        break;
      default:
        TwilioProgrammableChat._log("Event '$eventName' not yet implemented");
        break;
    }
  }
}

part of twilio_programmable_chat;

/// Provides access to channels collection, allows to create new channels.
class Channels {
  //#region Private API properties
  static final Map<String, Channel> _channelsMap = {};
  //#endregion

  //#region Public API properties
  /// Request list of user's joined channels.
  List<Channel> get subscribedChannels {
    return _channelsMap.values.where((channel) => channel._isSubscribed).toList();
  }
  //#endregion

  Channels();

  /// Construct from a map.
  factory Channels._fromMap(Map<String, dynamic> map) {
    var channels = Channels();
    channels._updateFromMap(map);
    return channels;
  }

  //#region Public API methods
  /// Create a [Channel] with friendly name and type.
  ///
  /// This operation creates a new channel entity on the backend.
  Future<Channel> createChannel(String friendlyName, ChannelType channelType) async {
    assert(channelType != null);
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Channels#createChannel', <String, Object>{'friendlyName': friendlyName, 'channelType': EnumToString.parse(channelType)});
      final channelMap = Map<String, dynamic>.from(methodData);
      _updateChannelFromMap(channelMap);
      return _channelsMap[channelMap['sid']];
    } on PlatformException catch (err) {
      if (err.code == 'ERROR' || err.code == 'IllegalArgumentException') {
        rethrow;
      }
      throw ErrorInfo(int.parse(err.code), err.message, err.details as int);
    }
  }

  /// Retrieves a [Channel] with the specified SID or unique name.
  Future<Channel> getChannel(String channelSidOrUniqueName) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Channels#getChannel', <String, Object>{'channelSidOrUniqueName': channelSidOrUniqueName});
      final channelMap = Map<String, dynamic>.from(methodData);
      _updateChannelFromMap(channelMap);
      return _channelsMap[channelMap['sid']];
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Request list of public channels that the current user has not joined.
  ///
  /// This command will return a list of [ChannelDescriptor]s. These are the channels that are public and are not joined by current user.
  /// To get channels already joined by current user see [Channels.getUserChannelsList].
  ///
  /// Returned list is wrapped in a [Paginator].
  Future<Paginator<ChannelDescriptor>> getPublicChannelsList() async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Channels#getPublicChannelsList');
      final paginatorMap = Map<String, dynamic>.from(methodData);
      return Paginator<ChannelDescriptor>._fromMap(paginatorMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Request list of channels user have joined.
  ///
  /// Per Android docs: This command will return a list of [ChannelDescriptor]s. These are the channels that are joined by current user, regardless of if they are public or private.
  /// To get public channels not yet joined by current user see [Channels.getPublicChannelsList].
  ///
  /// Per iOS docs: Retrieve a list of channel descriptors the user has a participation state on, for example invited, joined, creator.
  ///
  /// Returned list is wrapped in a [Paginator].
  Future<Paginator<ChannelDescriptor>> getUserChannelsList() async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Channels#getUserChannelsList');
      final paginatorMap = Map<String, dynamic>.from(methodData);
      return Paginator<ChannelDescriptor>._fromMap(paginatorMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get list of all [Channel] members with a given identity.
  ///
  /// The effect of this function is to find and return all Member instances across multiple channels with the given identity.
  Future<List<Member>> getMembersByIdentity(String identity) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Channels#getMembersByIdentity', {'identity': identity});
      final List<Map<String, dynamic>> memberMapList = methodData.map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();

      var memberList = [];
      for (final memberMap in memberMapList) {
        memberList.add(Member._fromMap(memberMap));
      }
      return memberList;
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    //TODO: update naming and utilization of this method
    if (map['subscribedChannels'] != null) {
      final List<Map<String, dynamic>> subscribedChannelsList = map['subscribedChannels'].map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();
      _channelsMap.values.forEach((channel) => channel._isSubscribed = false);
      for (final subscribedChannelMap in subscribedChannelsList) {
        var sid = subscribedChannelMap['sid'];
        _updateChannelFromMap(subscribedChannelMap);
        _channelsMap[sid]._isSubscribed = true;
      }
    }
  }

  /// Update individual channel from a map.
  static void _updateChannelFromMap(Map<String, dynamic> channelMap) {
    var sid = channelMap['sid'];
    if (_channelsMap[sid] == null) {
      _channelsMap[sid] = Channel._fromMap(channelMap);
      _channelsMap[sid]._isSubscribed = false;
    } else {
      _channelsMap[sid]._updateFromMap(channelMap);
    }
  }
}

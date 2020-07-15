part of twilio_programmable_chat;

/// Representation of a [Channel] member object.
class Member {
  //#region Private API properties
  final String _sid;

  final Attributes _attributes;

  int _lastConsumedMessageIndex;

  String _lastConsumptionTimestamp;

  String _channelSid;

  // TODO(WLFN): Could be final?
  String _identity;

  final MemberType _type;
  //#endregion

  //#region Public API properties
  /// Returns unique identifier of a member on a [Channel].
  String get sid {
    return _sid;
  }

  /// Returns members last consumed message index for this channel.
  int get lastConsumedMessageIndex {
    return _lastConsumedMessageIndex;
  }

  /// Return members last consumed message timestamp for this channel.
  String get lastConsumptionTimestamp {
    return _lastConsumptionTimestamp;
  }

  /// Returns user identity for the current member.
  String get identity {
    return _identity;
  }

  /// Returns [MemberType] of current member.
  MemberType get type {
    return _type;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }
  //#endregion

  Member(this._sid, this._type, this._channelSid, this._attributes)
      : assert(_sid != null),
        assert(_type != null),
        assert(_channelSid != null),
        assert(_attributes != null);

  /// Construct from a map.
  factory Member._fromMap(Map<String, dynamic> map) {
    if (map != null) {
      var member = Member(
        map['sid'],
        EnumToString.fromString(MemberType.values, map['type']),
        map['channelSid'],
        Attributes.fromMap(map['attributes'].cast<String, dynamic>()),
      );
      member._updateFromMap(map);
      return member;
    } else {
      return null;
    }
  }

  //#region Public API methods
  /// Returns the channel this member belong<s to.
  Future<Channel> getChannel() async {
    var channel = await TwilioProgrammableChat.chatClient.channels.getChannel(_channelSid);
    return channel;
  }

  /// Return user descriptor for current member.
  Future<UserDescriptor> getUserDescriptor() async {
    final userDescriptorData = await TwilioProgrammableChat._methodChannel.invokeMethod('Member#getUserDescriptor', {
      'identity': _identity,
      'channelSid': _channelSid,
    });
    final userDescriptor = UserDescriptor._fromMap(userDescriptorData.cast<String, dynamic>());
    return userDescriptor;
  }

  /// Return subscribed user object for current member.
  Future<User> getAndSubscribeUser() async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Member#getAndSubscribeUser', {
        'memberSid': _sid,
        'channelSid': _channelSid,
      });
      final userMap = Map<String, dynamic>.from(methodData);
      return User._fromMap(userMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set attributes associated with this member.
  Future<Map<String, dynamic>> setAttributes(Map<String, dynamic> attributes) async {
    try {
      return Map<String, dynamic>.from(await TwilioProgrammableChat._methodChannel.invokeMethod('Member#setAttributes', {'memberSid': _sid, 'channelSid': _channelSid, 'attributes': attributes}));
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _lastConsumedMessageIndex = map['lastConsumedMessageIndex'];
    _lastConsumptionTimestamp = map['lastConsumptionTimestamp'];
    _identity = map['identity'];
  }
}

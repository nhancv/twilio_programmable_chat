part of twilio_programmable_chat;

/// Contains channel information.
///
/// Unlike [Channel], this information won't be updated in realtime.
/// To have refreshed data, user should query channel descriptors again.
///
/// From the channel descriptor you could obtain full [Channel] object by calling [ChannelDescriptor.getChannel].
class ChannelDescriptor {
  //#region Private API properties
  final Channels _channels;

  final String _sid;

  String _friendlyName;

  String _uniqueName;

  Attributes _attributes;

  final ChannelStatus _status;

  final DateTime _dateCreated;

  DateTime _dateUpdated;

  final String _createdBy;

  int _membersCount;

  int _messagesCount;

  int _unconsumedMessagesCount;
  //#endregion

  //#region Public API properties
  /// Get channel SID.
  String get sid {
    return _sid;
  }

  /// Get channel friendly name.
  String get friendlyName {
    return _friendlyName;
  }

  /// Get channel unique name.
  String get uniqueName {
    return _uniqueName;
  }

  /// Get channel attributes.
  Attributes get attributes {
    return _attributes;
  }

  /// Get the current user's participation status on this channel.
  ///
  /// Since for [ChannelDescriptor]s the status is unknown this function will always return [ChannelStatus.UNKNOWN].
  ChannelStatus get status {
    return _status;
  }

  /// Get channel create date.
  DateTime get dateCreated {
    return _dateCreated;
  }

  /// Get channel update date.
  DateTime get dateUpdated {
    return _dateUpdated;
  }

  /// Get creator of the channel.
  String get createdBy {
    return _createdBy;
  }

  /// Get number of members.
  int get membersCount {
    return _membersCount;
  }

  /// Get number of messages.
  int get messagesCount {
    return _messagesCount;
  }

  /// Get number of unconsumed messages.
  int get unconsumedMessagesCount {
    return _unconsumedMessagesCount;
  }
  //#endregion

  ChannelDescriptor(
    this._sid,
    this._status,
    this._dateCreated,
    this._createdBy,
    this._channels,
  )   : assert(_sid != null),
        assert(_status != null),
        assert(_dateCreated != null),
        assert(_createdBy != null),
        assert(_channels != null);

  /// Construct from a map.
  factory ChannelDescriptor._fromMap(Map<String, dynamic> map, Channels channels) {
    var channelDescriptor = ChannelDescriptor(
      map['sid'],
      EnumToString.fromString(ChannelStatus.values, map['status']),
      DateTime.parse(map['dateCreated']),
      map['createdBy'],
      channels,
    );
    channelDescriptor._updateFromMap(map);
    return channelDescriptor;
  }

  //#region Public API methods
  /// Retrieve a full [Channel] object.
  Future<Channel> getChannel() async {
    return _channels.getChannel(_sid);
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _uniqueName = map['uniqueName'];
    assert(_uniqueName != null);
    _friendlyName = map['friendlyName'];
    assert(_friendlyName != null);
    _attributes = Attributes.fromMap(map['attributes'].cast<String, dynamic>());
    _dateUpdated = DateTime.parse(map['dateUpdated']);
    assert(_dateUpdated != null);
    _membersCount = map['membersCount'];
    assert(_membersCount != null);
    _messagesCount = map['messagesCount'];
    assert(_messagesCount != null);
    _unconsumedMessagesCount = map['unconsumedMessagesCount'];
    assert(_unconsumedMessagesCount != null);
  }
}

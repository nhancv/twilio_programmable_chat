part of twilio_programmable_chat;

class Message {
  //#region Private API properties
  final String _sid;

  final String _author;

  final DateTime _dateCreated;

  String _messageBody;

  final String _channelSid;

  final String _memberSid;

  final Member _member;

  final Messages _messages;

  final int _messageIndex;

  final MessageType _type;

  final bool _hasMedia;

  final MessageMedia _media;

  final Attributes _attributes;
  //#endregion

  //#region Public API properties
  /// Returns the identifier for this message.
  String get sid {
    return _sid;
  }

  /// The global identity of the author of this message.
  String get author {
    return _author;
  }

  /// The creation date for this message.
  DateTime get dateCreated {
    return _dateCreated;
  }

  /// The body for this message.
  String get messageBody {
    return _messageBody;
  }

  /// Returns the channel SID of the channel this message belongs to.
  String get channelSid {
    return _channelSid;
  }

  /// Returns the member SID of the member this message sent by.
  String get memberSid {
    return _memberSid;
  }

  /// Returns the member this message sent by.
  Member get member {
    return _member;
  }

  /// Returns the parent messages object this message belongs to.
  Messages get messages {
    return _messages;
  }

  /// Returns the index number for this message.
  int get messageIndex {
    return _messageIndex;
  }

  /// Returns message type.
  ///
  /// If message has media type then [Message.media] shall return the descriptor for the attached media.
  MessageType get type {
    return _type;
  }

  /// Helper method to check if message has media type.
  bool get hasMedia {
    return _hasMedia;
  }

  /// Get media descriptor of an associated media attachment, if exists.
  ///
  /// If the message type is [MessageType.TEXT] this method will return null.
  MessageMedia get media {
    return _media;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }
  //#endregion

  Message(
    this._sid,
    this._author,
    this._dateCreated,
    this._channelSid,
    this._memberSid,
    this._member,
    this._messages,
    this._messageIndex,
    this._type,
    this._hasMedia,
    this._media,
    this._attributes,
  )   : assert(_sid != null),
        assert(_author != null),
        assert(_dateCreated != null),
        assert(_channelSid != null),
        assert(_memberSid != null),
        assert(_messages != null),
        assert(_messageIndex != null),
        assert(_type != null),
        assert(_attributes != null),
        assert(_hasMedia != null),
        assert((_hasMedia == true && _media != null) || (_hasMedia == false && _media == null));

  /// Construct from a map.
  factory Message._fromMap(Map<String, dynamic> map, Messages messages) {
    var message = Message(
      map['sid'],
      map['author'],
      DateTime.parse(map['dateCreated']),
      map['channelSid'],
      map['memberSid'],
      Member._fromMap(map['member']?.cast<String, dynamic>()),
      messages,
      map['messageIndex'],
      EnumToString.fromString(MessageType.values, map['type']),
      map['hasMedia'],
      MessageMedia._fromMap(map['media']?.cast<String, dynamic>()),
      Attributes.fromMap(map['attributes'].cast<String, dynamic>()),
    );
    message._updateFromMap(map);
    return message;
  }

  //#region Public API methods
  /// Returns the parent channel this message belongs to.
  Future<Channel> getChannel() async {
    var channel = await TwilioProgrammableChat.chatClient.channels.getChannel(_channelSid);
    return channel;
  }

  /// Updates the body for a message.
  Future<void> updateMessageBody(String body) async {
    try {
      _messageBody = await TwilioProgrammableChat._methodChannel.invokeMethod('Message#updateMessageBody', {
        'channelSid': _channelSid,
        'messageIndex': _messageIndex,
        'body': body,
      });
    } on PlatformException catch (err) {
      throw throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set attributes associated with this message.
  Future<Map<String, dynamic>> setAttributes(Map<String, dynamic> attributes) async {
    try {
      return Map<String, dynamic>.from(await TwilioProgrammableChat._methodChannel.invokeMethod('Message#setAttributes', {
        'channelSid': _channelSid,
        'messageIndex': _messageIndex,
        'attributes': attributes,
      }));
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _messageBody = map['messageBody'];
  }
}

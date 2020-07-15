part of twilio_programmable_chat;

class Messages {
  final Channel _channel;

  //#region Private API properties
  int _lastConsumedMessageIndex;
  //#endregion

  //#region Public API properties
  /// Return user last consumed message index for the channel.
  int get lastConsumedMessageIndex {
    return _lastConsumedMessageIndex;
  }
  //#endregion

  Messages(this._channel) : assert(_channel != null);

  //#region Public API methods
  /// Sends a message to the channel.
  Future<Message> sendMessage(MessageOptions options) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#sendMessage', {
        'options': options.toMap(),
        'channelSid': _channel.sid,
      });
      final messageMap = Map<String, dynamic>.from(methodData);
      return Message._fromMap(messageMap, this);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Removes a message from the channel.
  Future<void> removeMessage(Message message) async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#removeMessage', {'channelSid': _channel.sid, 'messageIndex': message.messageIndex});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Fetch at most count messages including and prior to the specified index.
  Future<List<Message>> getMessagesBefore(int index, int count) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#getMessagesBefore', {
        'index': index,
        'count': count,
        'channelSid': _channel.sid,
      });
      final List<Map<String, dynamic>> messageMapList = methodData.map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();

      var messages = <Message>[];
      for (final messageMap in messageMapList) {
        messages.add(Message._fromMap(messageMap, this));
      }
      return messages;
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Fetch at most count messages including and subsequent to the specified index.
  Future<List<Message>> getMessagesAfter(int index, int count) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#getMessagesAfter', {
        'index': index,
        'count': count,
        'channelSid': _channel.sid,
      });
      final List<Map<String, dynamic>> messageMapList = methodData.map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();

      var messages = <Message>[];
      for (final messageMap in messageMapList) {
        messages.add(Message._fromMap(messageMap, this));
      }
      return messages;
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Load last messages in chat.
  Future<List<Message>> getLastMessages(int count) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#getLastMessages', {
        'count': count,
        'channelSid': _channel.sid,
      });
      final List<Map<String, dynamic>> messageMapList = methodData.map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();

      var messages = <Message>[];
      for (final messageMap in messageMapList) {
        messages.add(Message._fromMap(messageMap, this));
      }
      return messages;
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get message object by known index.
  Future<Message> getMessageByIndex(int messageIndex) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#getMessageByIndex', {'channelSid': _channel.sid, 'messageIndex': messageIndex});
      final messageMap = Map<String, dynamic>.from(methodData);
      return Message._fromMap(messageMap, this);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set user last consumed message index for the channel.
  Future<int> setLastConsumedMessageIndexWithResult(int lastConsumedMessageIndex) async {
    try {
      return _lastConsumedMessageIndex = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#setLastConsumedMessageIndexWithResult', {'channelSid': _channel.sid, 'lastConsumedMessageIndex': lastConsumedMessageIndex});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Increase user last consumed message index for the channel.
  ///
  /// Index is ignored if it is smaller than user current index.
  Future<int> advanceLastConsumedMessageIndexWithResult(int lastConsumedMessageIndex) async {
    try {
      return _lastConsumedMessageIndex = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#advanceLastConsumedMessageIndexWithResult', {'channelSid': _channel.sid, 'lastConsumedMessageIndex': lastConsumedMessageIndex});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set last consumed message index to last message index in channel.
  Future<int> setAllMessagesConsumedWithResult() async {
    try {
      return _lastConsumedMessageIndex = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#setAllMessagesConsumedWithResult', {'channelSid': _channel.sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set last consumed message index before the first message index in channel.
  Future<int> setNoMessagesConsumedWithResult() async {
    try {
      return _lastConsumedMessageIndex = await TwilioProgrammableChat._methodChannel.invokeMethod('Messages#setNoMessagesConsumedWithResult', {'channelSid': _channel.sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _lastConsumedMessageIndex = map['lastConsumedMessageIndex'];
  }
}

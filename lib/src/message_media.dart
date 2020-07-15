part of twilio_programmable_chat;

class MessageMedia {
  //#region Private API properties
  final String _sid;

  final String _fileName;

  final String _type;

  final int _size;

  final String _channelSid;

  final int _messageIndex;
  //#endregion

  //#region Public API properties
  /// Get SID of media stream.
  String get sid {
    return _sid;
  }

  /// Get file name of media stream.
  String get fileName {
    return _fileName;
  }

  /// Get mime-type of media stream.
  String get type {
    return _type;
  }

  /// Get size of media stream.
  int get size {
    return _size;
  }
  //#endregion

  MessageMedia(
    this._sid,
    this._fileName,
    this._type,
    this._size,
    this._channelSid,
    this._messageIndex,
  )   : assert(_sid != null),
        assert(_type != null),
        assert(_size != null),
        assert(_messageIndex != null);

  /// Construct from a map.
  factory MessageMedia._fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }
    return MessageMedia(map['sid'], map['fileName'], map['type'], map['size'], map['channelSid'], map['messageIndex']);
  }

  //#region Public API methods
  /// Save media content stream that could be streamed or downloaded by client.
  ///
  /// Provided file could be an existing file and a none existing file.
  Future<bool> download(File output) async {
    assert(output != null);
    return await TwilioProgrammableChat._methodChannel.invokeMethod('Message#getMedia', {
      'channelSid': _channelSid,
      'messageIndex': _messageIndex,
      'filePath': output.path,
    });
  }
  //#endregion
}

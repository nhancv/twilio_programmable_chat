part of twilio_programmable_chat;

class User {
  //#region Private API properties
  String _friendlyName;

  final Attributes _attributes;

  final String _identity;

  bool _isOnline;

  bool _isNotifiable;

  bool _isSubscribed;
  //#endregion

  //#region Public API properties
  /// Method that returns the friendlyName from the user info.
  String get friendlyName {
    return _friendlyName;
  }

  /// Returns the identity of the user.
  String get identity {
    return _identity;
  }

  /// Return user's online status, if available,
  // TODO(WLFN): Should probaly be a async method for real time
  bool get isOnline {
    return _isOnline;
  }

  /// Return user's push reachability.
  // TODO(WLFN): Should probaly be a async method for real time
  bool get isNotifiable {
    return _isNotifiable;
  }

  /// Check if this user receives real-time status updates.
  bool get isSubscribed {
    return _isSubscribed;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }
  //#endregion

  User(this._identity, this._attributes)
      : assert(_identity != null),
        assert(_attributes != null);

  /// Construct from a map.
  factory User._fromMap(Map<String, dynamic> map) {
    var user = User(
      map['identity'],
      Attributes.fromMap(map['attributes'].cast<String, dynamic>()),
    );
    user._updateFromMap(map);
    return user;
  }

  //#region Public API methods
  Future<void> unsubscribe() async {
    try {
      // TODO(WLFN): It is still in the [Users.subscribedUsers] list...
      await TwilioProgrammableChat._methodChannel.invokeMethod('User#unsubscribe', {'identity': _identity});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _friendlyName = map['friendlyName'];
    _isOnline = map['isOnline'];
    _isNotifiable = map['isNotifiable'];
    _isSubscribed = map['isSubscribed'];
  }
}

part of twilio_programmable_chat;

/// Contains user information.
///
/// Unlike [User], this information won't be updated in realtime. To have refreshed data, user should query user descriptors again.
/// From the user descriptor you could obtain full [User] object by calling [UserDescriptor.subscribe].
class UserDescriptor {
  final Users _users;

  final String _friendlyName;

  final Attributes _attributes;

  final String _identity;

  final bool _isOnline;

  final bool _isNotifiable;

  /// Get user friendly name.
  String get friendlyName {
    return _friendlyName;
  }

  /// Get user attributes.
  Attributes get attributes {
    return _attributes;
  }

  /// Get user identity.
  String get identity {
    return _identity;
  }

  /// [User] online status.
  bool get isOnline {
    return _isOnline;
  }

  /// [User] notifiable status.
  bool get isNotifiable {
    return _isNotifiable;
  }

  UserDescriptor(this._friendlyName, this._attributes, this._identity, this._isOnline, this._isNotifiable, this._users)
      : assert(_friendlyName != null),
        assert(_attributes != null),
        assert(_identity != null),
        assert(_isOnline != null),
        assert(_isNotifiable != null),
        assert(_users != null);

  /// Construct from a map.
  factory UserDescriptor._fromMap(Map<String, dynamic> map, Users users) {
    return UserDescriptor(
      map['friendlyName'],
      Attributes.fromMap(map['attributes'].cast<String, dynamic>()),
      map['identity'],
      map['isOnline'],
      map['isNotifiable'],
      users,
    );
  }

  /// Subscribe to the user object.
  Future<User> subscribe() async {
    return _users.getAndSubscribeUser(_identity);
  }
}

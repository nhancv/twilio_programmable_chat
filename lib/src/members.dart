part of twilio_programmable_chat;

/// Provides access to channel members and allows to add/remove members.
class Members {
  //#region Private API properties
  final String _channelSid;

  final List<Member> _membersList = [];
  //#endregion

  //#region Public API properties
  /// Return channel this member list belongs to.
  Future<Channel> get channel async {
    final channelData = await TwilioProgrammableChat._methodChannel.invokeMethod('Members#getChannel', {'channelSid': _channelSid});
    final channelMap = Map<String, dynamic>.from(channelData);
    return Channel._fromMap(channelMap);
  }

  /// Obtain an array of members of this channel.
  List<Member> get membersList {
    return [...membersList];
  }
  //#endregion

  Members(this._channelSid) : assert(_channelSid != null);

  /// Construct from a map.
  factory Members._fromMap(Map<String, dynamic> map) {
    var members = Members(map['channelSid']);
    members._updateFromMap(map);
    return members;
  }

  //#region Public API methods
  /// Get a channel member by identity.
  Member getMember(String identity) {
    return _membersList.firstWhere((m) => m.identity == identity, orElse: () => null);
  }

  /// Add member to the channel.
  ///
  /// The member object could refer to the member in some different channel, the add will be performed based on the member's identity.
  /// If the member is already present in the channel roster an error will be returned.
  Future<void> add(Member member) async {
    return addByIdentity(member.identity);
  }

  /// Add specified username to this channel without inviting.
  ///
  /// If the member is already present in the channel roster an error will be returned.
  Future<void> addByIdentity(String identity) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Members#addByIdentity', {'identity': identity, 'channelSid': _channelSid});
      final membersMap = Map<String, dynamic>.from(methodData);
      return _updateFromMap(membersMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Invite specified member to this channel.
  Future<void> invite(Member member) async {
    return inviteByIdentity(member.identity);
  }

  /// Invite specified username to this channel.
  Future<void> inviteByIdentity(String identity) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Members#removeByIdentity', {'identity': identity, 'channelSid': _channelSid});
      final membersMap = Map<String, dynamic>.from(methodData);
      return _updateFromMap(membersMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Remove specified member from this channel.
  Future<void> remove(Member member) async {
    return removeByIdentity(member.identity);
  }

  /// Remove specified username from this channel.
  Future<void> removeByIdentity(String identity) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Members#removeByIdentity', {'identity': identity, 'channelSid': _channelSid});
      final membersMap = Map<String, dynamic>.from(methodData);
      return _updateFromMap(membersMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    if (map['membersList'] != null) {
      final List<Map<String, dynamic>> membersList = map['membersList'].map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();
      for (final memberMap in membersList) {
        final member = _membersList.firstWhere(
          (m) => m._sid == memberMap['sid'],
          orElse: () => Member._fromMap(memberMap),
        );
        if (!_membersList.contains(member)) {
          _membersList.add(member);
        }
        member._updateFromMap(memberMap);
      }
    }
  }
}

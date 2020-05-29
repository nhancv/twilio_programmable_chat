part of twilio_programmable_chat;

enum UserUpdateReason {
  /// [User] attributes changed.
  ATTRIBUTES,

  /// [User] friendly name changed.
  FRIENDLY_NAME,

  /// Notifications reachability changed.
  REACHABILITY_NOTIFIABLE,

  /// Online status changed.
  REACHABILITY_ONLINE,
}

part of twilio_programmable_chat;

/// [User]'s notification level on a channel.
enum NotificationLevel {
  /// [User] will receive notifications for the channel if joined, nothing if unjoined.
  DEFAULT,

  /// [User] will not receive notifications for the channel.
  MUTED,
}

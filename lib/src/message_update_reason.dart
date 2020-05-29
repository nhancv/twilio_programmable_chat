part of twilio_programmable_chat;

/// Indicates reason for message update.
enum MessageUpdateReason {
  /// [Message] body has been updated.
  BODY,

  /// [Message] attributes have been updated.
  ATTRIBUTES,
}

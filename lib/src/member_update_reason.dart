part of twilio_programmable_chat;

/// Indicates reason for member info update.
enum MemberUpdateReason {
  /// [Member] last consumed message index has changed.
  LAST_CONSUMED_MESSAGE_INDEX,

  /// This update will be documented in the next SDK version.
  ATTRIBUTES,
}

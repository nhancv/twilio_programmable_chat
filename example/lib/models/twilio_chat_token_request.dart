import 'package:flutter/foundation.dart';

class TwilioChatTokenRequest {
  final String identity;

  TwilioChatTokenRequest({
    @required this.identity,
  });

  factory TwilioChatTokenRequest.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    return TwilioChatTokenRequest(
      identity: data['identity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identity': identity,
    };
  }
}

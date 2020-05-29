class TwilioChatTokenResponse {
  final String identity;
  final String token;

  TwilioChatTokenResponse({
    this.identity,
    this.token,
  });

  factory TwilioChatTokenResponse.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    return TwilioChatTokenResponse(
      identity: data['identity'],
      token: data['token'],
    );
  }
}

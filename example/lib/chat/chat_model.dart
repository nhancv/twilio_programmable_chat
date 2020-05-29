class ChatModel {
  final String token;

  ChatModel({this.token});

  bool get canSubmit {
    return true;
  }

  ChatModel copyWith() {
    return ChatModel(token: token ?? token);
  }
}

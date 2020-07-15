import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class JoinModel {
  final bool isLoading;
  final bool isSubmitted;
  final ChatClient chatClient;
  final String identity;

  JoinModel({this.isLoading = false, this.isSubmitted = false, this.chatClient, this.identity});

  bool get canSubmit {
    return identity?.isNotEmpty ?? false;
  }

  JoinModel copyWith({bool isLoading, bool isSubmitted, ChatClient chatClient, String identity}) {
    return JoinModel(chatClient: chatClient ?? this.chatClient, isLoading: isLoading ?? this.isLoading, isSubmitted: isSubmitted ?? this.isSubmitted, identity: identity ?? this.identity);
  }
}

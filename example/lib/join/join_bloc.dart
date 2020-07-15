import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat_example/models/twilio_chat_token_request.dart';
import 'package:twilio_programmable_chat_example/join/join_model.dart';
import 'package:twilio_programmable_chat_example/shared/services/backend_service.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class JoinBloc {
  final BackendService backendService;

  final BehaviorSubject<JoinModel> _modelSubject = BehaviorSubject<JoinModel>.seeded(JoinModel());

  JoinBloc({@required this.backendService}) : assert(backendService != null);

  Stream<JoinModel> get modelStream => _modelSubject.stream;

  JoinModel get model => _modelSubject.value;

  void dispose() {
    _modelSubject.close();
  }

  Future<void> submit() async {
    updateWith(isSubmitted: true, isLoading: true);
    try {
      final twilioRoomTokenResponse = await backendService.createToken(
        TwilioChatTokenRequest(identity: model.identity),
      );
      var properties = Properties();
      await TwilioProgrammableChat.debug(dart: true, native: true, sdk: false);
      var chatClient = await TwilioProgrammableChat.create(twilioRoomTokenResponse.token, properties);
      updateWith(identity: twilioRoomTokenResponse.identity, chatClient: chatClient);
    } catch (err) {
      rethrow;
    } finally {
      updateWith(isLoading: false);
    }
  }

  void updateIdentity(String identity) => updateWith(identity: identity);

  void updateWith({
    bool isLoading,
    bool isSubmitted,
    ChatClient chatClient,
    String identity,
  }) {
    _modelSubject.value = model.copyWith(
      isLoading: isLoading,
      isSubmitted: isSubmitted,
      chatClient: chatClient,
      identity: identity,
    );
  }
}

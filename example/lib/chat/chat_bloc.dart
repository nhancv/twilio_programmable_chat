import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class ChatBloc {
  final ChatClient chatClient;

  StreamController<List<ChannelDescriptor>> _channelDescriptorController;

  StreamSink<List<ChannelDescriptor>> get channelDescriptorSink => _channelDescriptorController.sink;

  Stream<List<ChannelDescriptor>> get channelDescriptorStream => _channelDescriptorController.stream;

  ChatBloc({@required this.chatClient}) : assert(chatClient != null) {
    _channelDescriptorController = StreamController<List<ChannelDescriptor>>();
  }

  Future<void> retrieve() async {
    _channelDescriptorController.add(null);
    var paginator = await chatClient.channels.getPublicChannelsList();
    _channelDescriptorController.add(paginator.items);
  }

  void dispose() {
    _channelDescriptorController.close();
  }
}

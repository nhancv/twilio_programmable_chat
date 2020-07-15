import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class ChatModel {
  final bool isLoading;
  final List<ChannelDescriptor> publicChannels;
  final List<ChannelDescriptor> userChannels;

  ChatModel({
    this.isLoading = false,
    this.publicChannels = const <ChannelDescriptor>[],
    this.userChannels = const <ChannelDescriptor>[],
  });

  ChatModel copyWith({
    bool isLoading,
    List<ChannelDescriptor> publicChannels,
    List<ChannelDescriptor> userChannels,
  }) {
    return ChatModel(
      isLoading: isLoading ?? this.isLoading,
      publicChannels: publicChannels ?? this.publicChannels,
      userChannels: userChannels ?? this.userChannels,
    );
  }
}

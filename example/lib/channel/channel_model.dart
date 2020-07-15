import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class ChannelModel {
  String friendlyName;
  List<Message> messages;

  ChannelModel({this.friendlyName = '', this.messages = const <Message>[]});

  ChannelModel addMessage(Message message) {
    var messageList = <Message>[...messages, message];
    return copyWith(messages: messageList);
  }

  ChannelModel copyWith({String friendlyName, List<Message> messages}) {
    return ChannelModel(
      friendlyName: friendlyName ?? this.friendlyName,
      messages: messages ?? this.messages,
    );
  }
}

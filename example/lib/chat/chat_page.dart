import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/chat/chat_bloc.dart';
import 'package:twilio_programmable_chat_example/join/join_model.dart';

class ChatPage extends StatefulWidget {
  final ChatBloc chatBloc;

  const ChatPage({
    Key key,
    @required this.chatBloc,
  }) : super(key: key);

  static Widget create(BuildContext context, JoinModel joinModel) {
    return Provider<ChatBloc>(
      create: (BuildContext context) => ChatBloc(chatClient: joinModel.chatClient),
      child: Consumer<ChatBloc>(
        builder: (BuildContext context, ChatBloc chatBloc, _) => ChatPage(
          chatBloc: chatBloc,
        ),
      ),
      dispose: (BuildContext context, ChatBloc chatBloc) => chatBloc.dispose(),
    );
  }

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isLoading = false;

  List<ChannelDescriptor> items = [];

  @override
  void initState() {
    super.initState();
    widget.chatBloc.channelDescriptorStream.listen(_onChannelDescriptor);
    widget.chatBloc.retrieve();
  }

  void _onChannelDescriptor(List<ChannelDescriptor> channelDescriptors) {
    if (channelDescriptors == null) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = false;
        items.addAll(channelDescriptors);
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _channelList() {
    return Container(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length) {
            return _buildProgressIndicator();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage('https://placehold.it/400x400'),
                  radius: 32.0,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(items[index].friendlyName, style: TextStyle(fontSize: 16.0)),
                    Text('Members: ${items[index].membersCount}'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: _channelList(),
      ),
    );
  }
}

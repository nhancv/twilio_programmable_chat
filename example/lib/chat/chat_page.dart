import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/channel/channel_page.dart';
import 'package:twilio_programmable_chat_example/chat/add_channel_dialog.dart';
import 'package:twilio_programmable_chat_example/chat/chat_bloc.dart';
import 'package:twilio_programmable_chat_example/chat/chat_model.dart';
import 'package:twilio_programmable_chat_example/join/join_model.dart';

class ChatPage extends StatefulWidget {
  final ChatBloc chatBloc;

  const ChatPage({
    Key key,
    @required this.chatBloc,
  }) : super(key: key);

  static Widget create(BuildContext context, JoinModel joinModel) {
    return Provider<ChatBloc>(
      create: (BuildContext context) => ChatBloc(
        myIdentity: joinModel.identity,
        chatClient: joinModel.chatClient,
      ),
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
  @override
  void initState() {
    super.initState();
    widget.chatBloc.retrieve();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => widget.chatBloc.retrieve(),
            )
          ],
        ),
        body: _channelList(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showAddChannelDialog,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNoChannelsFound() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text('No Channels Found'),
      ),
    );
  }

  Widget _channelList() {
    return StreamBuilder(
        initialData: ChatModel(isLoading: true),
        stream: widget.chatBloc.channelDescriptorStream,
        builder: (BuildContext context, AsyncSnapshot<ChatModel> snapshot) {
          var chatModel = snapshot.data;
          var publicChannels = chatModel.publicChannels.where((publicChannel) => !chatModel.userChannels.any((userChannel) => userChannel.sid == publicChannel.sid)).toList();
          var channels = [...chatModel.userChannels, ...publicChannels];

          if (chatModel.isLoading) {
            return _buildProgressIndicator();
          } else if (channels.isEmpty) {
            return _buildNoChannelsFound();
          }

          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: channels.length,
                itemBuilder: (BuildContext context, int index) {
                  var channelDescriptor = channels[index];
                  return _buildChannel(channelDescriptor, widget.chatBloc.channelStatusMap[channelDescriptor.sid]);
                },
              )
            ],
          );
        });
  }

  Widget _buildChannel(ChannelDescriptor channel, ChannelStatus status) {
    return InkWell(
      onTap: () => _joinChannel(channel),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(padding: const EdgeInsets.all(8.0), child: _buildChannelIndicator(status)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(channel.friendlyName, style: TextStyle(fontSize: 16.0)),
                Row(
                  children: <Widget>[
                    Text('Members: ${channel.membersCount}'),
                    SizedBox(width: 12),
                    Text('Unread: ${widget.chatBloc.unreadMessagesMap[channel.sid] ?? channel.messagesCount}'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editChannel(channel),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => widget.chatBloc.destroyChannel(channel),
          )
        ],
      ),
    );
  }

  Widget _buildChannelIndicator(ChannelStatus status) {
    return Icon(
      status == ChannelStatus.JOINED ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      color: status != ChannelStatus.JOINED ? status == ChannelStatus.INVITED ? Colors.yellow : Colors.grey : Colors.green,
    );
  }

  Future _showAddChannelDialog() async {
    var result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          return AddChannelDialog();
        });
    if (result != null && result['name'] != null && result['name'].isNotEmpty) {
      await widget.chatBloc.addChannel(result['name'], result['type']);
    }
  }

  Future _joinChannel(ChannelDescriptor channelDescriptor) async {
    var channel = await channelDescriptor.getChannel();
    if (channel.status != ChannelStatus.JOINED) {
      await widget.chatBloc.joinChannel(channel);
    }
    await Navigator.of(context).push(MaterialPageRoute<ChannelPage>(
      builder: (BuildContext context) => ChannelPage.create(
        context,
        widget.chatBloc.myIdentity,
        widget.chatBloc.chatClient,
        channelDescriptor,
      ),
    ));
    await widget.chatBloc.retrieve();
  }

  Future _editChannel(ChannelDescriptor channelDescriptor) async {
    var _controller = TextEditingController(text: channelDescriptor.friendlyName);
    var result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Edit Channel:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Channel Name',
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(null),
                      ),
                      RaisedButton(
                        child: Text('Update'),
                        onPressed: () => Navigator.of(context).pop(_controller.value.text),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
    if (result != null && result.isNotEmpty) {
      await widget.chatBloc.updateChannel(channelDescriptor, result);
    }
  }
}

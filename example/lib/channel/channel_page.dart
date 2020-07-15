import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/channel/channel_bloc.dart';
import 'package:twilio_programmable_chat_example/channel/channel_model.dart';
import 'package:twilio_programmable_chat_example/channel/media_model.dart';
import 'package:twilio_programmable_chat_example/invite/invite_page.dart';
import 'package:twilio_programmable_chat_example/members/members_page.dart';

class ChannelPage extends StatefulWidget {
  final ChannelBloc channelBloc;

  const ChannelPage({
    Key key,
    @required this.channelBloc,
  }) : super(key: key);

  static Widget create(
    BuildContext context,
    String myUsername,
    ChatClient chatClient,
    ChannelDescriptor channelDescriptor,
  ) {
    return Provider<ChannelBloc>(
      create: (BuildContext context) => ChannelBloc(myUsername: myUsername, chatClient: chatClient, channelDescriptor: channelDescriptor),
      child: Consumer<ChannelBloc>(
        builder: (BuildContext context, ChannelBloc channelBloc, _) => ChannelPage(
          channelBloc: channelBloc,
        ),
      ),
      dispose: (BuildContext context, ChannelBloc channelBloc) => channelBloc.dispose(),
    );
  }

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<ChannelModel>(
          stream: widget.channelBloc.messageStream,
          initialData: ChannelModel(),
          builder: (BuildContext context, AsyncSnapshot<ChannelModel> snapshot) {
            var model = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (widget.channelBloc.channel?.type == ChannelType.PRIVATE)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.lock_outline),
                        ),
                      Text('${model.friendlyName}'),
                    ],
                  ),
                  actions: <Widget>[
                    PopupMenuButton<ChatMenuOptions>(
                      onSelected: _onPopMenuItemSelected,
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<ChatMenuOptions>(
                            value: ChatMenuOptions.Members,
                            child: Text('Members'),
                          ),
                          const PopupMenuItem<ChatMenuOptions>(
                            value: ChatMenuOptions.Invite,
                            child: Text('Invite'),
                          ),
                          const PopupMenuItem<ChatMenuOptions>(
                            value: ChatMenuOptions.Leave,
                            child: Text('Leave'),
                          ),
                        ];
                      },
                    ),
                  ]),
              body: _buildBody(model),
            );
          }),
    );
  }

  Widget _buildBody(ChannelModel model) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          model.messages.isNotEmpty
              ? Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: widget.channelBloc.scrollController,
                      itemCount: model.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildMessage(model.messages[index]);
                      },
                    ),
                  ),
                )
              : Expanded(
                  child: Container(
                    child: Center(
                      child: Text('No messages in channel ${model.friendlyName}'),
                    ),
                  ),
                ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                stream: widget.channelBloc.typingStream,
                initialData: null,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  var data = snapshot.data;
                  if (data != null) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$data is typing...'),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: widget.channelBloc.sendImage,
                ),
                Expanded(
                  child: TextFormField(
                    controller: widget.channelBloc.messageController,
                    decoration: InputDecoration(hintText: 'Enter your message here...'),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    await widget.channelBloc.sendMessage();
                    await widget.channelBloc.scrollController.jumpTo(widget.channelBloc.scrollController.position.maxScrollExtent);
                    setState(() {
                      widget.channelBloc.messageController.text = '';
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    var currentUserIsAuthor = messageFromMe(message);
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: currentUserIsAuthor ? 46 : 6,
        right: currentUserIsAuthor ? 6 : 46,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: currentUserIsAuthor ? Colors.lightGreen : Colors.blueGrey,
          border: Border(),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: !message.hasMedia
                    ? Text(
                        message.messageBody ?? '',
                        style: TextStyle(color: Colors.white),
                        softWrap: true,
                      )
                    : StreamBuilder(
                        stream: widget.channelBloc.mediaSubjects[message.sid],
                        initialData: MediaModel(isLoading: true, message: message),
                        builder: (BuildContext context, AsyncSnapshot<MediaModel> snapshot) {
                          var data = snapshot.data;
                          // Set height/width on Containers to avoid jank
                          if (data.isLoading) {
                            return Container(
                              height: 220,
                              width: 220,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            print('ChannelPage => building message sid: ${message.sid} index: ${message.messageIndex} file: ${data.file.path}');
                            return Container(
                              height: 220,
                              width: 220,
                              child: Center(
                                child: Image.file(
                                  data.file,
                                  height: 200,
                                  width: 200,
                                ),
                              ),
                            );
                          }
                        },
                      )),
            Column(
              children: <Widget>[
                Text('${(doesNameExist(message)) ? message.attributes?.getJSONObject()['name'] : 'UNKNOWN'}', style: TextStyle(color: Colors.white)),
                Text(_formatMessageCreationTime(message), style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool messageFromMe(Message message) {
    return message.author == widget.channelBloc.chatClient.myIdentity;
  }

  bool doesNameExist(Message message) => message.attributes != null && message.attributes.type == AttributesType.OBJECT && message.attributes.getJSONObject().containsKey('name');

  String _formatMessageCreationTime(Message message) {
    var dateCreated = message.dateCreated;
    if (dateCreated.difference(DateTime.now()).inDays > 0) {
      return '${dateCreated.month} ${dateCreated.day} @ ${dateCreated.hour}:${dateCreated.minute}';
    } else {
      return '${dateCreated.hour}:${dateCreated.minute}';
    }
  }

  void _onPopMenuItemSelected(ChatMenuOptions option) {
    switch (option) {
      case ChatMenuOptions.Members:
        _showMembers();
        break;
      case ChatMenuOptions.Leave:
        _leaveChannel();
        break;
      case ChatMenuOptions.Invite:
        _inviteToChannel();
        break;
    }
  }

  Future _showMembers() async {
    await Navigator.of(context).push(MaterialPageRoute<MembersPage>(
      builder: (BuildContext context) => MembersPage.create(
        context,
        widget.channelBloc.myUsername,
        widget.channelBloc.chatClient,
        widget.channelBloc.channelDescriptor,
      ),
    ));
  }

  Future _leaveChannel() async {
    if (widget.channelBloc.channel.type == ChannelType.PRIVATE && widget.channelBloc.channel.createdBy == widget.channelBloc.myUsername) {
      var leavePrivateChannel = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('You created this channel'),
              content: Text('If you leave this channel, it will be deleted since you created it.'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                RaisedButton(
                  child: Text('Leave'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          });
      if (leavePrivateChannel) {
        await widget.channelBloc.leaveChannel();
        Navigator.of(context).pop();
      }
    } else {
      await widget.channelBloc.leaveChannel();
      Navigator.of(context).pop();
    }
  }

  Future _inviteToChannel() async {
    await Navigator.of(context).push(MaterialPageRoute<InvitePage>(
      builder: (BuildContext context) => InvitePage.create(
        context,
        widget.channelBloc.myUsername,
        widget.channelBloc.chatClient,
        widget.channelBloc.channelDescriptor,
      ),
    ));
  }
}

enum ChatMenuOptions {
  Members,
  Leave,
  Invite,
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/members/members_bloc.dart';

class MembersPage extends StatefulWidget {
  final MembersBloc membersBloc;

  MembersPage({this.membersBloc});

  @override
  State<StatefulWidget> createState() => MembersPageState();

  static Widget create(
    BuildContext context,
    String myUsername,
    ChatClient chatClient,
    ChannelDescriptor channelDescriptor,
  ) {
    return Provider<MembersBloc>(
      create: (BuildContext context) => MembersBloc(chatClient: chatClient, channelDescriptor: channelDescriptor),
      child: Consumer<MembersBloc>(
        builder: (BuildContext context, MembersBloc membersBloc, _) => MembersPage(
          membersBloc: membersBloc,
        ),
      ),
      dispose: (BuildContext context, MembersBloc membersBloc) => membersBloc.dispose(),
    );
  }
}

class MembersPageState extends State<MembersPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Members'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: widget.membersBloc.refresh,
            ),
          ],
        ),
        body: _buildMembersList(),
      ),
    );
  }

  Widget _buildMembersList() {
    return StreamBuilder<MemberData>(
      stream: widget.membersBloc.membersStream,
      initialData: MemberData(),
      builder: (BuildContext context, AsyncSnapshot<MemberData> snapshot) {
        var memberData = snapshot.data;
        return ListView.builder(
          itemCount: memberData.members.length,
          itemBuilder: (BuildContext context, int index) {
            var member = memberData.members[index];
            var userDescriptor = memberData.userDescriptors[member.sid];
            return Row(
              children: <Widget>[
                Icon(
                  userDescriptor?.isOnline ?? false ? Icons.person : Icons.perm_identity,
                  color: userDescriptor?.isOnline ?? false ? Colors.green : Colors.grey,
                ),
                Text(member.identity)
              ],
            );
          },
        );
      },
    );
  }
}

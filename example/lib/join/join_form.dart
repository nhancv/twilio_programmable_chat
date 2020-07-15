import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twilio_programmable_chat_example/chat/chat_page.dart';
import 'package:twilio_programmable_chat_example/join/join_bloc.dart';
import 'package:twilio_programmable_chat_example/join/join_model.dart';
import 'package:twilio_programmable_chat_example/shared/services/backend_service.dart';

class JoinForm extends StatefulWidget {
  final JoinBloc joinBloc;

  const JoinForm({
    Key key,
    @required this.joinBloc,
  }) : super(key: key);

  static Widget create(BuildContext context) {
    final backendService = Provider.of<BackendService>(context, listen: false);
    return Provider<JoinBloc>(
      create: (BuildContext context) => JoinBloc(backendService: backendService),
      child: Consumer<JoinBloc>(
        builder: (BuildContext context, JoinBloc joinBloc, _) => JoinForm(
          joinBloc: joinBloc,
        ),
      ),
      dispose: (BuildContext context, JoinBloc joinBloc) => joinBloc.dispose(),
    );
  }

  @override
  _JoinFormState createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final TextEditingController _nameController = TextEditingController();
  VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () => widget.joinBloc.updateIdentity(_nameController.text);
    _nameController.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JoinModel>(
        stream: widget.joinBloc.modelStream,
        initialData: JoinModel(),
        builder: (BuildContext context, AsyncSnapshot<JoinModel> snapshot) {
          final joinModel = snapshot.data;
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildChildren(joinModel),
            ),
          );
        });
  }

  List<Widget> _buildChildren(JoinModel chatModel) {
    return <Widget>[
      TextField(
        decoration: InputDecoration(
          labelText: 'Enter Username',
          enabled: !chatModel.isLoading,
        ),
        controller: _nameController,
        onChanged: widget.joinBloc.updateIdentity,
      ),
      const SizedBox(
        height: 16,
      ),
      const SizedBox(
        height: 16,
      ),
      _buildButton(chatModel),
      const SizedBox(
        height: 16,
      ),
    ];
  }

  Widget _buildButton(JoinModel chatModel) {
    return chatModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : FlatButton(
            onPressed: chatModel.canSubmit && !chatModel.isLoading ? _submit : null,
            child: const Text('JOIN'),
            color: Theme.of(context).appBarTheme?.color ?? Theme.of(context).primaryColor,
            textColor: Theme.of(context).appBarTheme?.textTheme?.headline6?.color ?? Colors.white,
            disabledColor: Colors.grey.shade300,
          );
  }

  Future<void> _submit() async {
    try {
      await widget.joinBloc.submit();
      await Navigator.of(context).push(
        MaterialPageRoute<ChatPage>(fullscreenDialog: true, builder: (BuildContext context) => ChatPage.create(context, widget.joinBloc.model)),
      );
    } on PlatformException catch (error) {
      print(error);
//      await PlatformExceptionAlertDialog(
//        title: 'Error creating room',
//        exception: error,
//      ).show(context);
    }
  }
}

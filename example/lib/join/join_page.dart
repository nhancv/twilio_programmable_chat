import 'package:flutter/material.dart';
import 'package:twilio_programmable_chat_example/join/join_form.dart';

class JoinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twilio Programmable Chat'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: JoinForm.create(context),
        ),
      ),
    );
  }
}

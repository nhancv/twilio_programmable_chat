import 'package:flutter/material.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class AddChannelDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddChannelDialogState();
}

class _AddChannelDialogState extends State<AddChannelDialog> {
  final _controller = TextEditingController();
  var _channelType = ChannelType.PUBLIC;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Add Channel:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Channel Name',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 44,
                    width: 140,
                    child: RadioListTile<ChannelType>(
                      groupValue: _channelType,
                      value: ChannelType.PUBLIC,
                      title: const Text('Public'),
                      selected: _channelType == ChannelType.PUBLIC,
                      onChanged: (type) => setState(() {
                        _channelType = type;
                      }),
                    ),
                  ),
                  Container(
                    height: 44,
                    width: 160,
                    child: RadioListTile<ChannelType>(
                      groupValue: _channelType,
                      value: ChannelType.PRIVATE,
                      title: const Text('Private'),
                      selected: _channelType == ChannelType.PRIVATE,
                      onChanged: (type) => setState(() {
                        _channelType = type;
                      }),
                    ),
                  ),
                ],
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
                  child: Text('Add'),
                  onPressed: () => Navigator.of(context).pop({
                    'name': _controller.value.text,
                    'type': _channelType,
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/channel/channel_model.dart';
import 'package:twilio_programmable_chat_example/channel/media_model.dart';

class ChannelBloc {
  BehaviorSubject<ChannelModel> _messageSubject;
  ValueStream<ChannelModel> messageStream;
  BehaviorSubject<String> _typingSubject;
  ValueStream<String> typingStream;
  List<StreamSubscription> _subscriptions;
  Map<String, BehaviorSubject<MediaModel>> mediaSubjects = <String, BehaviorSubject<MediaModel>>{};

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String myUsername;
  String tempDirPath;
  ChatClient chatClient;
  ChannelDescriptor channelDescriptor;
  Channel channel;

  ChannelBloc({@required this.myUsername, @required this.chatClient, @required this.channelDescriptor})
      : assert(myUsername != null),
        assert(chatClient != null),
        assert(channelDescriptor != null) {
    _messageSubject = BehaviorSubject<ChannelModel>();
    _messageSubject.add(ChannelModel());
    messageStream = _messageSubject.stream;
    _subscriptions = <StreamSubscription>[];
    _typingSubject = BehaviorSubject<String>();
    typingStream = _typingSubject.stream;
    messageController.addListener(_onTyping);

    channelDescriptor.getChannel().then((channel) {
      this.channel = channel;
      _subscribeToChannel();
      channel.getFriendlyName().then((friendlyName) {
        _messageSubject.add(
          _messageSubject.value.copyWith(friendlyName: friendlyName),
        );
      });
    });
  }

  Future _onTyping() async {
    await channel.typing();
  }

  Future _subscribeToChannel() async {
    print('ChannelBloc::subscribeToChannel');
    if (channel.hasSynchronized) {
      await _getMessages(channel);
    }

    _subscriptions.add(channel.onSynchronizationChanged.listen((event) async {
      if (event.synchronizationStatus == ChannelSynchronizationStatus.ALL) {
        await _getMessages(event);
      }
    }));
    _subscriptions.add(channel.onMessageAdded.listen((Message message) {
      _messageSubject.add(_messageSubject.value.addMessage(message));
      if (message.hasMedia) {
        _getImage(message);
      }
    }));
    _subscriptions.add(channel.onTypingStarted.listen((TypingEvent event) {
      _typingSubject.add(event.member.identity);
    }));
    _subscriptions.add(channel.onTypingEnded.listen((TypingEvent event) {
      _typingSubject.add(null);
    }));
  }

  Future _getMessages(Channel channel) async {
    var friendlyName = await channel.getFriendlyName();
    var messageCount = await channel.getMessagesCount();
    var messages = await channel.messages.getLastMessages(messageCount);
    messages.where((message) => message.hasMedia).forEach(_getImage);
    _messageSubject.add(_messageSubject.value.copyWith(
      friendlyName: friendlyName,
      messages: messages,
    ));
    await _updateLastConsumedMessageIndex(channel, messages);
  }

  Future _updateLastConsumedMessageIndex(Channel channel, List<Message> messages) async {
    var lastConsumedMessageIndex = (messages?.length ?? 0) > 0 ? messages.last.messageIndex : 0;
    await channel.messages.setLastConsumedMessageIndexWithResult(lastConsumedMessageIndex);
  }

  Future sendMessage() async {
    var message = MessageOptions()
      ..withBody(messageController.text)
      ..withAttributes({'name': myUsername});
    await channel.messages.sendMessage(message);
  }

  Future sendImage() async {
    var image = await _imagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
      var file = File(image.path);
      var mimeType = mime(image.path);
      var message = MessageOptions()
        ..withMedia(file, mimeType)
        ..withAttributes({'name': myUsername});
      await channel.messages.sendMessage(message);
    }
  }

  Future leaveChannel() async {
    if (channel.type == ChannelType.PUBLIC) {
      return channel.leave();
    } else {
      await channel.leave();
      return channel.destroy();
    }
  }

  Future _getImage(Message message) async {
    var subject = BehaviorSubject<MediaModel>();
    subject.add(MediaModel(isLoading: true, message: message));
    mediaSubjects[message.sid] = subject;

    if (tempDirPath == null) {
      var tempDir = await getTemporaryDirectory();
      tempDirPath = tempDir.path;
    }
    var path = '$tempDirPath/'
        '${(message.media.fileName != null && message.media.fileName.isNotEmpty) ? message.media.fileName : message.media.sid}.'
        '${extensionFromMime(message.media.type)}';
    var outputFile = File(path);

    await message.media.download(outputFile);
    subject.add(subject.value.copyWith(isLoading: false, file: outputFile));
  }

  Future dispose() async {
    await _messageSubject.close();
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    messageController.removeListener(_onTyping);
  }
}

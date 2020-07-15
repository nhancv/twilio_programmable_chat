import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/chat/chat_model.dart';

class ChatBloc {
  final String myIdentity;
  final ChatClient chatClient;

  BehaviorSubject<ChatModel> _channelDescriptorController;
  ValueStream<ChatModel> get channelDescriptorStream => _channelDescriptorController.stream;
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];
  final List<StreamSubscription> _channelSubscriptions = <StreamSubscription>[];
  Map<String, int> unreadMessagesMap = {};
  Map<String, ChannelStatus> channelStatusMap = {};

  ChatBloc({@required this.myIdentity, @required this.chatClient}) : assert(chatClient != null) {
    _channelDescriptorController = BehaviorSubject<ChatModel>();
    _subscriptions.add(chatClient.onChannelAdded.listen((event) {
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelDeleted.listen((event) {
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelUpdated.listen((event) {
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelSynchronizationChange.listen((event) {
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelInvited.listen((event) {
      retrieve();
    }));
  }

  Future addChannel(String channelName, ChannelType type) async {
    assert(type != null);
    _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: true));
    var channel = await chatClient.channels.createChannel(channelName, type);
    if (channel != null) await retrieve();
  }

  Future joinChannel(Channel channel) async {
    assert(channel != null);
    channel.onSynchronizationChanged.listen((event) {
      retrieve();
    });
    await channel.join();
  }

  Paginator<ChannelDescriptor> publicChannelPaginator;
  Paginator<ChannelDescriptor> userChannelPaginator;

  Future retrieve() async {
    _channelDescriptorController.add(ChatModel(isLoading: true));
    _channelSubscriptions.forEach((sub) => sub.cancel());
    _channelSubscriptions.clear();
    unreadMessagesMap.clear();

    // TODO: Handle pagination, don't litter
    var userChannelPaginator = await chatClient.channels.getUserChannelsList();
    var publicChannelPaginator = await chatClient.channels.getPublicChannelsList();

    for (var channelDescriptor in userChannelPaginator.items) {
      var channel = await channelDescriptor.getChannel();
      await _updateUnreadMessageCountForChannel(channelDescriptor);
      channelStatusMap[channel.sid] = channel.status;

      _channelSubscriptions.add(channel.onMemberAdded.listen((event) {
        retrieve();
      }));
      _channelSubscriptions.add(channel.onMemberDeleted.listen((event) {
        retrieve();
      }));
    }

    for (var channelDescriptor in publicChannelPaginator.items) {
      var channel = await channelDescriptor.getChannel();
      await _updateUnreadMessageCountForChannel(channelDescriptor);
      channelStatusMap[channel.sid] = channel.status;

      _channelSubscriptions.add(channel.onMemberAdded.listen((event) {
        retrieve();
      }));
      _channelSubscriptions.add(channel.onMemberDeleted.listen((event) {
        retrieve();
      }));
    }
    _channelDescriptorController.add(ChatModel(publicChannels: publicChannelPaginator.items, userChannels: userChannelPaginator.items));
  }

  Future _updateUnreadMessageCountForChannel(ChannelDescriptor channelDescriptor) async {
    var userHasJoined = (await channelDescriptor.status) == ChannelStatus.JOINED;
    if (!userHasJoined) {
      unreadMessagesMap[channelDescriptor.sid] = channelDescriptor.messagesCount;
    } else {
      unreadMessagesMap[channelDescriptor.sid] = await channelDescriptor.unconsumedMessagesCount;
    }
  }

  Future destroyChannel(ChannelDescriptor channelDescriptor) async {
    try {
      _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: true));
      var channel = await channelDescriptor.getChannel();
      if (channel != null) {
        await channel.destroy();
        await retrieve();
      }
    } catch (e) {
      _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: false));
    }
  }

  Future updateChannel(ChannelDescriptor channelDescriptor, String name) async {
    _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: true));
    var channel = await channelDescriptor.getChannel();
    if (channel != null) {
      await channel.setFriendlyName(name);
      await retrieve();
    }
  }

  void dispose() {
    _channelDescriptorController.close();
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();
  }
}

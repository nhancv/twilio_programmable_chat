# twilio_programmable_chat
Integrate the Twilio Chat SDK with your Flutter app using this Twilio Programmable Chat Flutter plugin.

This package is currently work-in-progress and should not be used for production apps. We can't guarantee that the current API implementation will stay the same between versions, until we have reached v1.0.0.

## Join the community
If you have any question or problems, please join us on [Discord](https://discord.gg/42x46NH)

## FAQ
Read the [Frequently Asked Questions](https://gitlab.com/twilio-flutter/programmable-chat/blob/master/FAQ.md) first before creating a new issue.

## Supported platforms
* Android (WIP)
* ~~iOS~~ (not yet)
* ~~Web~~ (not yet)

## Getting started

### Prerequisites
Before you can start using the plugin you need to make sure you have everything setup for your project.

First add it as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).  
For example:
```yaml
dependencies:
  twilio_programmable_chat: '^0.1.0'
```

## Events table
Reference table of all the events the plugin supports and their native platform counter part.

| Type       | Event name                     | Android                          | Implemented |
| :--------- | ------------------------------ | -------------------------------- | ----------- |
| ChatClient | addedToChannelNotification     | onAddedToChannelNotification     |             |
| ChatClient | channelAdded                   | onChannelAdded                   | X           | 
| ChatClient | channelDeleted                 | onChannelDeleted                 | X           |
| ChatClient | channelInvited                 | onChannelInvited                 | X           |
| ChatClient | channelJoined                  | onChannelJoined                  | X           |
| ChatClient | channelSynchronizationChange   | onChannelSynchronizationChange   | X           |
| ChatClient | channelUpdated                 | onChannelUpdated                 | X           |
| ChatClient | clientSynchronization          | onClientSynchronization          | X           |
| ChatClient | connectionStateChange          | onConnectionStateChange          | X           |
| ChatClient | error                          | onError                          | X           |
| ChatClient | invitedToChannelNotification   | onInvitedToChannelNotification   |             |
| ChatClient | newMessageNotification         | onNewMessageNotification         |             |
| ChatClient | notificationSubscribed         | onNotificationSubscribed         | X           |
| ChatClient | notificationFailed             | onNotificationFailed             | X           |
| ChatClient | removedFromChannelNotification | onRemovedFromChannelNotification |             |
| ChatClient | tokenAboutToExpire             | onTokenAboutToExpire             | X           |
| ChatClient | onTokenExpired                 | onTokenExpired                   | X           |
| ChatClient | userSubscribed                 | onUserSubscribed                 | X           |
| ChatClient | userUnsubscribed               | onUserUnsubscribed               | X           |
| ChatClient | userUpdated                    | onUserUpdated                    | X           |

# Example
Check out our comprehensive [example](https://gitlab.com/twilio-flutter/programmable-chat/tree/master/example) provided with this plugin.

# Development and Contributing
Interested in contributing? We love merge requests! See the [Contribution](https://gitlab.com/twilio-flutter/programmable-chat/blob/master/CONTRIBUTING.md) guidelines.

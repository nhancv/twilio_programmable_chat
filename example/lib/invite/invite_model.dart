import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class InviteModel {
  bool isLoading;
  Map<String, Member> membersMap;
  List<Member> get members => membersMap.values.toList();

  InviteModel({
    this.membersMap = const {},
    this.isLoading = false,
  });

  InviteModel copyWith({bool isLoading, Map<String, Member> membersMap}) {
    return InviteModel(
      membersMap: membersMap ?? this.membersMap,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

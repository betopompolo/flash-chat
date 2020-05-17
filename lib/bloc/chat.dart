import 'package:flash_chat/bloc/user.dart';

class Chat {
  String id;
  List<User> participants;
  final DateTime createAt;

  Chat({
    this.id,
    this.participants,
    this.createAt,
  });
}
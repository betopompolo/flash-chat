import 'package:flash_chat/bloc/user.dart';

class Message {
  final String chatId;
  final String text;
  final DateTime sentAt;
  final User to;
  final User from;

  Message({this.chatId, this.text, this.to, this.from, this.sentAt});
}
import 'package:flash_chat/bloc/user.dart';

class Message {
  final String chatId;
  final String text;
  final DateTime sentAt;
  final User receiver;
  final User sender;

  Message({this.chatId, this.text, this.receiver, this.sender, this.sentAt});
}
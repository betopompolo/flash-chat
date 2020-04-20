import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/resources/chat_repository.dart';

class ChatMessagesBloc with Bloc {
  final _chatRepository = ChatRepository();

  Stream<List<Message>> getChatMessagesStream(Chat chat) {
    return _chatRepository.getMessagesStream(chat).map((messages) {
      messages.sort(_sortBySendAt);
      return messages;
    });
  }

  int _sortBySendAt(Message message1, Message message2) {
    return message1.sentAt.isAfter(message2.sentAt) ? 1 : -1;
  }

  Future<Message> sendMessage(Message message) {
    return _chatRepository.addMessage(message);
  }

  @override
  void dispose() {
  }
}
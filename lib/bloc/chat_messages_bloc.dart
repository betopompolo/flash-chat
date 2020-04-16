import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/resources/chat_repository.dart';

class ChatMessagesBloc with Bloc {
  final _chatMessageController = StreamController<List<Message>>();
  final _chatRepository = ChatRepository();

  ChatMessagesBloc(Chat chat) {
    _setChatMessagesStream(chat);
  }

  Stream<List<Message>> get stream => _chatMessageController.stream;

  _setChatMessagesStream(Chat chat) {
    _chatMessageController.addStream(_chatRepository.getMessagesStream(chat));
  }

  @override
  void dispose() {
    _chatMessageController.close();
  }
}
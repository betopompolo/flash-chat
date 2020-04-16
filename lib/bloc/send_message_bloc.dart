import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/resources/chat_repository.dart';

class SendMessageBloc with Bloc {
  final _chatMessageController = StreamController<Message>();
  final _chatRepository = ChatRepository();

  Future addMessage(Message message) async {
    Message createdMessage = await _chatRepository.addMessage(message);
    _chatMessageController.sink.add(createdMessage);
  }

  Stream<Message> get stream => _chatMessageController.stream;

  @override
  void dispose() {
    _chatMessageController.close();
  }
}
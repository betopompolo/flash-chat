import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/resources/chat_repository.dart';
import 'package:flash_chat/resources/user_repository.dart';

class ChatMessagesBloc with Bloc {
  final _chatRepository = ChatRepository();
  final _userRepository = UserRepository();

  final _chatStreamController = StreamController<List<Chat>>();
  get chatStream => _chatStreamController.stream;
  StreamSubscription<List<Chat>> _chatStreamListener;

  ChatMessagesBloc() {
    _chatStreamListener = _chatRepository.listChatStream().listen(_handleChatStream);
  }

  @override
  void dispose() {
    _chatStreamController.close();
    _chatStreamListener.cancel();
  }

  _handleChatStream(List<Chat> chats) async {
    chats.sort(_sortChatsByCreatedAt);

    for (Chat chat in chats) {
      chat.participants = await Future.wait(_getChatParticipantsDetails(chat));
    }

    _chatStreamController.sink.add(chats);
  }

  Stream<List<Message>> getChatMessagesStream(Chat chat) {
    return _chatRepository.getMessagesStream(chat).map((messages) {
      messages.sort(_sortMessagesBySendAt);
      return messages;
    });
  }

  List<Future<User>> _getChatParticipantsDetails(Chat chat) {
    return chat?.participants?.map((user) => _userRepository.getById(user.id))?.toList();
  }

  int _sortChatsByCreatedAt(Chat chat1, Chat chat2) {
    return chat1.createAt.isBefore(chat2.createAt) ? -1 : 1;
  }

  int _sortMessagesBySendAt(Message message1, Message message2) {
    return message1.sentAt.isAfter(message2.sentAt) ? 1 : -1;
  }

  Future<Message> sendMessage(Message message) {
    return _chatRepository.addMessage(message);
  }

  Future<Chat> createChat(List<User> participants, { addLoggedUserInParticipants = true }) async {
    if (participants.isEmpty) {
      return null;
    }

    if (addLoggedUserInParticipants) {
      final loggedUser = await _userRepository.getLoggedUser();
      if (loggedUser != null) {
        participants.add(loggedUser);
      }
    }

    Chat newChat = Chat(
      createAt: DateTime.now(),
      participants: participants,
    );

    return _chatRepository.createChat(newChat);
  }
}
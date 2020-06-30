import 'dart:async';

import 'package:flash_chat/domain/bloc.dart';
import 'package:flash_chat/domain/chat.dart';
import 'package:flash_chat/domain/message.dart';
import 'package:flash_chat/domain/user.dart';
import 'package:flash_chat/domain/user_bloc.dart';
import 'package:flash_chat/data/chat_repository.dart';

class ChatMessagesBloc with Bloc {
  final _chatRepository = ChatRepository();
  final _userBloc = UserBloc();

  final _chatStreamController = StreamController<List<Chat>>();
  get chatStream => _chatStreamController.stream;
  StreamSubscription<List<Chat>> _chatStreamSubscription;

  final _chatMessageStreamController = StreamController<List<Message>>();
  get messageStream => _chatMessageStreamController.stream;
  StreamSubscription<List<Message>> _chatMessageSubscription;

  @override
  void dispose() {
    _chatMessageSubscription?.cancel();
    _chatStreamSubscription?.cancel();
    _chatStreamController.close();
    _chatMessageStreamController.close();
  }

  setChatStreamForUser(User user) {
    if (_chatStreamSubscription != null) {
      _chatStreamSubscription.cancel();
    }

    _chatStreamSubscription = _chatRepository.chatListStream(user).listen(_handleChatStream);
  }

  _handleChatStream(List<Chat> chats) async {
    chats.sort(_sortChatsByCreatedAt);

    for (Chat chat in chats) {
      chat.participants = await Future.wait(_getChatParticipantsDetails(chat));
    }

    _chatStreamController.sink.add(chats);
  }

  setChatMessage(Chat chat) {
    if (_chatMessageSubscription != null) {
      _chatMessageSubscription.cancel();
    }

    _chatMessageSubscription = _chatRepository.getMessagesStream(chat).listen((messages) { 
      messages.sort(_sortMessagesBySendAt);
      _chatMessageStreamController.sink.add(messages);
    });
  }

  List<Future<User>> _getChatParticipantsDetails(Chat chat) {
    return chat?.participants?.map((user) => _userBloc.getUserById(user.id))?.toList();
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

  Future<Chat> createChat(List<User> participants, { includeLoggedUser = true }) async {
    if (participants.isEmpty) {
      return null;
    }
    final loggedUser = _userBloc.loggedUser;

    if (includeLoggedUser && loggedUser != null) {
      participants.add(loggedUser);
    }

    Chat newChat = Chat(
      createAt: DateTime.now(),
      participants: participants,
    );

    return _chatRepository.createChat(newChat);
  }
}
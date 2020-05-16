import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
import 'package:flash_chat/resources/chat_repository.dart';

class ChatMessagesBloc with Bloc {
  final _chatRepository = ChatRepository();
  final _userBloc = UserBloc();

  final _chatStreamController = StreamController<List<Chat>>();
  get chatStream => _chatStreamController.stream;
  StreamSubscription<List<Chat>> _chatStreamListener;

  final _chatMessageStreamController = StreamController<List<Message>>();
  get messageStream => _chatMessageStreamController.stream.asBroadcastStream();
  StreamSubscription<List<Message>> _chatMessageSubscription;

  ChatMessagesBloc() {
    _chatStreamListener = _chatRepository.listChatStream().listen(_handleChatStream);
  }

  @override
  void dispose() {
    _chatMessageSubscription.cancel();
    _chatStreamListener.cancel();
    _chatStreamController.close();
    _chatMessageStreamController.close();
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

    if (includeLoggedUser && _userBloc.loggedUser != null) {
      participants.add(_userBloc.loggedUser);
    }

    Chat newChat = Chat(
      createAt: DateTime.now(),
      participants: participants,
    );

    return _chatRepository.createChat(newChat);
  }
}
import 'package:flash_chat/domain/chat.dart';
import 'package:flash_chat/domain/chat_messages_bloc.dart';
import 'package:flash_chat/domain/user.dart';
import 'package:flash_chat/domain/user_bloc.dart';
import 'package:flash_chat/ui/components/bloc_provider.dart';
import 'package:flash_chat/ui/screens/chat_screen.dart';
import 'package:flash_chat/ui/screens/new_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatListScreen extends StatefulWidget {
  static String name = 'ChatListScreen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatBloc = ChatMessagesBloc();
  User _loggedUser;

  @override
  void dispose() {
    _chatBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _loggedUser = BlocProvider.of<UserBloc>(context).loggedUser;
        _chatBloc.setChatStreamForUser(_loggedUser);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: _showLogoutDialog,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createNewChat(context),
          ),
        ],
        title: Text('Chat List'),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _chatBloc.chatStream,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.hasError || _loggedUser == null) {
            final message = _loggedUser == null ? 'No logged user 😑' : 'Something went wrong 😱';
            return Center(
              child: Text(message),
            );
          }

          List<Chat> chats = snapshot.data?.reversed?.toList();

          if (chats == null || chats.isEmpty) {
            return Center(
              child: Text('Click on the + icon to start a chat'),
            );
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final displayUser = _getDisplayUser(chat, _loggedUser);

                    return ListTile(
                      title: Text(displayUser.displayName),
                      subtitle: Text(displayUser.email),
                      onTap: () {
                        Navigator.pushNamed(context, ChatScreen.name, arguments: ChatScreenArgs(
                          chat: chat,
                        ));
                      },
                    );
                  },
                separatorBuilder: (context, index) => Divider(),
                itemCount: chats.length,
              )),
            ],
          );
        },
      ),
    );
  }

  User _getDisplayUser(Chat chat, User loggedUser) {
    final chatParticipants = List<User>.from(chat.participants);
    chatParticipants.removeWhere((participant) => loggedUser.id == participant.id);

    return chatParticipants.isEmpty ? null : chatParticipants.first;
  }

  _showLogoutDialog() {
    final content = Text('Do you really want to logout?');
    final dismissDialog = () => Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: content,
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: dismissDialog,
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () async {
              await _logout();
              dismissDialog();
            },
          ),
        ],
      ),
    );
  }

  _logout() {
    Navigator.pop(context);
  }

  _createNewChat(BuildContext context) async {
    final newChat = await Navigator.pushNamed(context, NewChatScreen.name);

    if (newChat is Chat) {
      await Navigator.pushNamed(context, ChatScreen.name, arguments: ChatScreenArgs(
        chat: newChat
      ));
    }
  }
}

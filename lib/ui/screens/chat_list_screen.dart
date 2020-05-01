import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/chat_messages_bloc.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
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
  final _userBloc = UserBloc();
  final _chatBloc = ChatMessagesBloc();

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
            onPressed: () => Navigator.pushNamed(context, NewChatScreen.name),
          ),
        ],
        title: Text('Chat List'),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _chatBloc.chatStream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong 😱'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Chat> chats = snapshot.data.reversed.toList();

          if (chats.isEmpty) {
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
                    final displayUser = chat.participantsWithoutLoggedUser[0];

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
    _userBloc.logout();
    Navigator.pop(context);
  }
}

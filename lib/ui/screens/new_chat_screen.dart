import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/chat_messages_bloc.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
import 'package:flash_chat/ui/components/bloc_provider.dart';
import 'package:flash_chat/ui/screens/chat_screen.dart';
import 'package:flash_chat/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewChatScreen extends StatefulWidget {
  static final name = 'NewChatScreen';
  
  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _chatMessagesBloc = ChatMessagesBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Chat'),
      ),
      body: UserSearch(
        onUserTap: _createNewChat,
      ),
    );
  }

  _createNewChat(User receiver) async {
    Chat newChat = await _chatMessagesBloc.createChat([
      receiver,
    ]);
    ChatScreenArgs args = ChatScreenArgs(
      chat: newChat,
    );
    Navigator.popAndPushNamed(context, ChatScreen.name, arguments: args);
  }
}

class UserSearch extends StatefulWidget {
  final Function(User) onUserTap;

  UserSearch({ this.onUserTap });

  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  final _searchTextFieldController = TextEditingController();
  bool _hideSearchProgress = true;

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            decoration: kTextFieldDecoration.copyWith(hintText: 'Type user`s display name or email'),
            onEditingComplete: () {
              if (_hideSearchProgress) {
                setState(() {
                  _hideSearchProgress = false;
                });
              }
              userBloc.search(User(
                displayName: _searchTextFieldController.text,
                email: _searchTextFieldController.text,
              ));
            },
            textInputAction: TextInputAction.search,
            controller: _searchTextFieldController,
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
                stream: userBloc.searchStream,
                initialData: [],
                builder: (context, snapshot) {
                  List<User> searchResults = snapshot.data;

                  if (_hideSearchProgress) {
                    return Container();
                  }

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

                  if (searchResults.isEmpty) {
                    return Center(
                      child: Text('No user has been found :('),
                    );
                  }

                  return ListView.separated(
                    itemBuilder: (context, index) {
                      User user = searchResults[index];

                      return ListTile(
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        onTap: () => _handleUserTap(user),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(height: 1.0,),
                    itemCount: searchResults.length,
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  _handleUserTap(User user) {
    if (widget.onUserTap != null) {
      widget.onUserTap(user);
    }
  }
}


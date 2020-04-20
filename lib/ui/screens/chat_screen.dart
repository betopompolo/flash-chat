import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/chat_messages_bloc.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
import 'package:flash_chat/ui/components/message_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/ui/styles.dart';


class ChatScreen extends StatefulWidget {
  static final String name = 'ChatScreen';

  // TODO: Receive a chat via props
  final Chat chat = Chat('rdjPM4koiGffOxoa5THd', DateTime.now());

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageTextFieldController = TextEditingController();
  final _chatMessagesBloc = ChatMessagesBloc();
  final _userBloc = UserBloc();
  Stream<List<Message>> _chatMessageStream;

  @override
  void initState() {
    super.initState();
    _chatMessageStream = _chatMessagesBloc.getChatMessagesStream(widget.chat);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: _userBloc.authUserStream,
      initialData: User('', ''),
      builder: (context, snapshot) {
        User user = snapshot.data;

        if (user == null) {
          print('nothing here :(');
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: _showLogoutDialog,
            ),
            title: Text('${user.displayName}'),
            backgroundColor: Colors.lightBlueAccent,
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: MessageList(
                    loggedUser: user,
                    messageStream: _chatMessageStream,
                  ),
                ),
                Container(
                  decoration: kMessageContainerDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: kMessageTextFieldDecoration,
                          controller: _messageTextFieldController,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (value) => _sendMessage(user),
                        ),
                      ),
                      FlatButton(
                        onPressed: () => _sendMessage(user),
                        child: Text(
                          'Send',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _logout() {
    _userBloc.logout();
    Navigator.pop(context);
  }

  _sendMessage(User loggedUser) async {
    final message = Message(
      text: _messageTextFieldController.text,
      sender: loggedUser,
      sentAt: DateTime.now(),
      receiver: User('Fabio', 'f.nassu@gmail.com'), //TODO: Remove
      chatId: widget.chat.id,
    );
    _messageTextFieldController.clear();
    await _chatMessagesBloc.sendMessage(message);
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
}

class MessageList extends StatelessWidget {
  final User loggedUser;
  final Stream<List<Message>> messageStream;

  MessageList({
    this.loggedUser,
    this.messageStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasError) {
          return Center(
            child: Text('We could not retrieve the messages :('),
          );
        }

        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<Message> messages = snapshot.data.reversed.toList();

        if (messages.isEmpty) {
          return Center(
            child: Text('Nothing to show here...'),
          );
        }

        return ListView.separated(
          itemBuilder: (context, index) => _buildMessage(messages[index]),
          separatorBuilder: (context, index) => SizedBox(height: 4.0,),
          itemCount: messages.length,
          padding: EdgeInsets.all(8.0),
          reverse: true,
        );
      },
    );
  }

  Widget _buildMessage(Message message) {
    bool isMe = loggedUser.email == message.sender.email;
    
    return MessageBubble(
      text: message.text,
      backgroundColor: Colors.lightBlueAccent,
      isMe: isMe,
    );
  }
}


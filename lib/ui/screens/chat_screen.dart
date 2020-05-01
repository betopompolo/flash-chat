import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/chat_messages_bloc.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
import 'package:flash_chat/ui/components/message_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/ui/styles.dart';


class ChatScreenArgs {
  final Chat chat;

  ChatScreenArgs({
    this.chat,
  });
}

class ChatScreen extends StatefulWidget {
  static final String name = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageTextFieldController = TextEditingController();
  final _chatMessagesBloc = ChatMessagesBloc();
  final _userBloc = UserBloc();

  Stream<List<Message>> _chatMessageStream;

  ChatScreenArgs get _screenArgs => ModalRoute.of(context).settings.arguments;
  User get _receiver => _screenArgs.chat.participants[0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_chatMessageStream == null) {
      _chatMessageStream = _chatMessagesBloc.getChatMessagesStream(_screenArgs.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_receiver == null) {
      return Container();
    }

    return StreamBuilder<User>(
      stream: _userBloc.authUserStream,
      initialData: User(),
      builder: (context, snapshot) {
        User user = snapshot.data;

        if (user == null) {
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${_receiver.displayName}'),
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

  _sendMessage(User loggedUser) async {
    final message = Message(
      text: _messageTextFieldController.text,
      sender: loggedUser,
      sentAt: DateTime.now(),
      receiver: _receiver,
      chatId: _screenArgs.chat.id,
    );
    _messageTextFieldController.clear();
    await _chatMessagesBloc.sendMessage(message);
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


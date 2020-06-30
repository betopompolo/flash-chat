import 'package:flash_chat/domain/chat.dart';
import 'package:flash_chat/domain/chat_messages_bloc.dart';
import 'package:flash_chat/domain/message.dart';
import 'package:flash_chat/domain/user.dart';
import 'package:flash_chat/domain/user_bloc.dart';
import 'package:flash_chat/ui/components/bloc_provider.dart';
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

  ChatScreenArgs get _screenArgs => ModalRoute.of(context).settings.arguments;
  User get _receiver => _screenArgs.chat.participants[0];
  User _loggedUser;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _chatMessagesBloc.setChatMessage(_screenArgs.chat);

      this.setState(() {
        _loggedUser = BlocProvider.of<UserBloc>(context).loggedUser;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _chatMessagesBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_receiver == null || _loggedUser == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Text('Something went wrong 🤔'),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _chatMessagesBloc.messageStream,
                builder: (context, snapshot) {
                  final isLoading = snapshot.connectionState == ConnectionState.waiting;
                  final messages = snapshot.data;

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

                  return MessageList(
                    loggedUser: _loggedUser,
                    messages: messages,
                  );
                },
              )
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
                      onSubmitted: (value) => _sendMessage(_loggedUser),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => _sendMessage(_loggedUser),
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
  }

  _buildAppBar() => AppBar(
    title: Text('${_receiver.displayName}'),
  );

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
  final List<Message> messages;

  MessageList({
    this.loggedUser,
    this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final List<Message> displayMessages = messages.reversed.toList();
    
    if (displayMessages.isEmpty) {
      return Center(
        child: Text('Nothing to show here...'),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) => _buildMessage(displayMessages[index]),
      separatorBuilder: (context, index) => SizedBox(
        height: 4.0,
      ),
      itemCount: displayMessages.length,
      padding: EdgeInsets.all(8.0),
      reverse: true,
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

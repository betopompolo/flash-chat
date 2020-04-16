import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/ui/components/message_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/ui/styles.dart';

final Firestore _fireStore = Firestore.instance;
final String messagesCollection = 'messages';
final FirebaseAuth _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static final String name = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseUser _user;
  String _textMessage;
  final messageTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _auth.currentUser().then((user) {
      setState(() {
        _user = user;  
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _showLogoutDialog();
          },
        ),
        title: Text('${_user?.displayName}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: MessageList(
                loggedUser: _user,
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                      controller: messageTextFieldController,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _sendMessage();
                      messageTextFieldController.clear();
                    },
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

  _logout() {
    _auth.signOut();
    Navigator.pop(context);
  }

  _sendMessage() {
    _fireStore.collection(messagesCollection).add({
      'sender': _user.email,
      'text': _textMessage,
    });
  }

  _showLogoutDialog() {
    final content = Text('Do you really want to logout?');
    final dismissDialog = () {
      Navigator.pop(context);
    };

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
  final FirebaseUser loggedUser;

  MessageList({
    this.loggedUser,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection(messagesCollection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final List<DocumentSnapshot> messages = snapshot.data.documents.reversed.toList();

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

  Widget _buildMessage(DocumentSnapshot message) {
    bool isMe = loggedUser.email == message.data['sender'];
    
    return MessageBubble(
      text: message.data['text'],
      backgroundColor: Colors.lightBlueAccent,
      isMe: isMe,
    );
  }
}


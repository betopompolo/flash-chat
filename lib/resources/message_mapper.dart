import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/bloc/user.dart';

class MessageMapper {

  static Message mapDocumentSnapshot(DocumentSnapshot snapshot) {
    final Timestamp timestamp = snapshot.data['send_timestamp'];
    final sender = User(email: snapshot.data['sender_email']);
    final receiver = User(email: snapshot.data['receiver_email']);

    return Message(
      chatId: snapshot.data['chat_id'],
      sender: sender,
      receiver: receiver,
      text: snapshot.data['text'],
      sentAt: DateTime.fromMillisecondsSinceEpoch(timestamp?.millisecondsSinceEpoch),
    );
  }

  static List<Message> mapQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map(MessageMapper.mapDocumentSnapshot).toList();
  }

  static Map<String, dynamic> mapToFirebase(Message message) => {
    'chat_id': message.chatId,
    'sender_email': message.sender.email,
    'receiver_email': message.receiver.email,
    'send_timestamp': Timestamp.fromDate(message.sentAt),
    'text': message.text,
  };
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/bloc/message.dart';

class MessageMapper {

  static Message mapDocumentSnapshot(DocumentSnapshot snapshot) {
    final Timestamp timestamp = snapshot.data['send_timestamp'];

    return Message(
      chatId: snapshot.data['chat_id'],
      from: snapshot.data['from'],
      to: snapshot.data['to'],
      text: snapshot.data['text'],
      sentAt: DateTime.fromMillisecondsSinceEpoch(timestamp?.millisecondsSinceEpoch),
    );
  }

  static List<Message> mapQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map(MessageMapper.mapDocumentSnapshot);
  }
}
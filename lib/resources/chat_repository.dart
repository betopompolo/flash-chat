import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/resources/message_mapper.dart';

class ChatRepository {
  Firestore get _firestore => Firestore.instance;
  final _messagesCollection = 'messages';
      
  Stream<List<Message>> getMessagesStream(Chat chat) {
    return _firestore.collection(_messagesCollection).snapshots().map((snapshot) {
      final List<Message> messages = snapshot.documents.map(MessageMapper.mapDocumentSnapshot);
      
      return messages.where((message) => message.chatId == chat.id).toList();
    });
  }

  Future<Message> addMessage(Message message) async {
    await _firestore.collection(_messagesCollection).add({
      'chat_id': message.chatId,
      'send_timestamp': Timestamp.fromDate(message.sentAt),
      'to': message.to.email,
      'from': message.from.email,
      'text': message.text,
    });

    return message;
  }
}
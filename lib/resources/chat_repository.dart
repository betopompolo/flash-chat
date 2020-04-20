import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/message.dart';
import 'package:flash_chat/resources/message_mapper.dart';

class ChatRepository {
  Firestore get _firestore => Firestore.instance;
  final _messagesCollection = 'messages';


  Stream<List<Message>> getMessagesStream(Chat chat) {
    return _firestore
        .collection(_messagesCollection)
        .where('chat_id', isEqualTo: chat.id)
        .snapshots()
        .map(MessageMapper.mapQuerySnapshot);
  }

  Future<Message> addMessage(Message message) async {
    await _firestore.collection(_messagesCollection).add(MessageMapper.mapToFirebase(message));

    return message;
  }
}
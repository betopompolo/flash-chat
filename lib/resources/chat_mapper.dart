import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/bloc/chat.dart';
import 'package:flash_chat/bloc/user.dart';

class ChatMapper {
  static Map<String, dynamic> mapToFirestore(Chat chat) {
    final fireStoreChat = {
      'start_at': Timestamp.fromDate(chat.createAt),
      'participants_ids': chat.participants?.map((user) => user.id)?.toList(),
    };

    return fireStoreChat;
  }

  static List<Chat> mapQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((document) {
      final Timestamp startAt = document.data['start_at'];
      final createdAt = startAt.toDate();

      final List<dynamic> participantsIds = document.data['participants_ids'];
      final chatParticipants = participantsIds.map<User>((userId) => User(id: userId)).toList();

      final chat = Chat(
        id: document.documentID,
        createAt: createdAt,
        participants: chatParticipants,
      );
      
      return chat;
    }).toList();
  }
}
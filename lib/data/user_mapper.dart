import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/bloc/user.dart';

class UserMapper {
  static User mapFirebaseUser(FirebaseUser user) {
    return User(
      displayName: user.displayName,
      email: user.email,
    );
  }

  static Map<String, dynamic> mapToFirestore(User user) {
    return {
      'display_name': user.displayName,
      'email': user.email,
    };
  }

  static List<User> mapQuerySnapshot(QuerySnapshot query) {
    return query.documents.map(UserMapper.mapDocumentSnapshot).toList();
  }

  static User mapDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot == null) {
      return null;
    }

    return User(
      id: documentSnapshot.documentID,
      displayName: documentSnapshot.data['display_name'],
      email: documentSnapshot.data['email'],
    );
  }
}
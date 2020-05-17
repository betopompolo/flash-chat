import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/resources/user_mapper.dart';

class UserRepository {
  FirebaseAuth get _fireAuth => FirebaseAuth.instance;
  Firestore get _fireStore => Firestore.instance;
  
  final _userCollectionName = 'users';

  Stream<User> getAuthUserStream() {
    return _fireAuth.onAuthStateChanged.map((user) {
      return user != null ? UserMapper.mapFirebaseUser(user) : null;
    });
  }

  Future login(User user, String password) {
    return _fireAuth.signInWithEmailAndPassword(email: user.email, password: password);
  }

  Future logout() => _fireAuth.signOut();

  Future<User> getLoggedUser() async {
    final firebaseUser = await _fireAuth.currentUser();
    final authUser = UserMapper.mapFirebaseUser(firebaseUser);
    
    final user = await getByEmail(authUser.email);
    if (user != null) {
      return user;
    } 
    
    return authUser;
  }

  Future<User> createUser(User user, String password) async {
    final userInfo = UserUpdateInfo();
    userInfo.displayName = user.displayName;

    await _fireAuth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    ).then((result) => result.user.updateProfile(userInfo));

    return user;
  }
  
  Future<User> saveInFirestore(User user) async {
    final userDocument = await _fireStore.collection(_userCollectionName).add(UserMapper.mapToFirestore(user));
    user.id = userDocument.documentID;

    return user;
  }

  Future<User> getById(String userId) async {
    final userDocument = await _fireStore.collection(_userCollectionName).document(userId).get();

    return UserMapper.mapDocumentSnapshot(userDocument);
  }

  Future<User> getByEmail(String userEmail) async {
    final searchResults = await searchByEmail(userEmail);
    if (searchResults != null && searchResults.isNotEmpty) {
      return searchResults.first;
    }
    return null;
  }

  Future<List<User>> searchByEmail(String email) {
    return _fireStore
      .collection(_userCollectionName)
      .where('email', isEqualTo: email)
      .snapshots()
      .handleError((error) => <User>[])
      .map((querySnapshot) => UserMapper.mapQuerySnapshot(querySnapshot))
      .first;
  }

  Future<List<User>> searchByDisplayName(String displayName) {
    return _fireStore
        .collection(_userCollectionName)
        .where('display_name', isEqualTo: displayName)
        .snapshots()
        .handleError((error) => <User>[])
        .map((querySnapshot) => UserMapper.mapQuerySnapshot(querySnapshot))
        .first;
  }
}
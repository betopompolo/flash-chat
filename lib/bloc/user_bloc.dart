import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/data/user_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class UserBloc with Bloc {
  final _userRepository = UserRepository();

  final _authUserController = BehaviorSubject<User>();
  ValueStream<User> get authUserStream => _authUserController.stream;
  StreamSubscription<User> _authUserStreamSubscription;

  final _searchStreamController = StreamController<List<User>>();
  Stream<List<User>> get searchStream =>_searchStreamController.stream;

  User get loggedUser => authUserStream.value;

  UserBloc() {
    _authUserStreamSubscription = _userRepository.getAuthUserStream().listen(_handleAuthUserStream);
  }

  _handleAuthUserStream(User authUser) async {
    if (authUser == null) {
      return;
    }

    final user = await _userRepository.getByEmail(authUser.email);
    _authUserController.sink.add(user);
  }

  Future login(User user, String password) {
    return _userRepository.login(user, password);
  }

  Future logout() => _userRepository.logout();

  Future<User> registerUser(User user, String password, { loginAfterRegister = false }) async {
    final createdUser = await _userRepository.createUser(user, password);
    final userDetails = await _userRepository.saveInFirestore(createdUser);
    if (loginAfterRegister) {
      _authUserController.sink.add(userDetails);
    }

    return userDetails;
  }

  search(User user) async {
    _searchStreamController.sink.add(null);
    List<User> emailSearchResults = await _userRepository.searchByEmail(user.email);
    List<User> displayNameSearchResults = await _userRepository.searchByDisplayName(user.displayName);
    
    List<User> searchResults = (emailSearchResults + displayNameSearchResults) ?? [];

    _searchStreamController.sink.add(searchResults);
  }

  Future<User> getUserById(String userId) {
    return _userRepository.getById(userId);
  }

  @override
  void dispose() {
    _authUserStreamSubscription.cancel();
    _authUserController.close();
    _searchStreamController.close();
  }
}
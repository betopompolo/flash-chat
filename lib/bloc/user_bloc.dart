import 'dart:async';

import 'package:flash_chat/bloc/bloc.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/resources/user_repository.dart';

class UserBloc with Bloc {
  final _userRepository = UserRepository();

  final _authUserController = StreamController<User>();
  Stream<User> get authUserStream => _authUserController.stream.asBroadcastStream();
  StreamSubscription<User> _authUserStreamSubscription;

  final _searchStreamController = StreamController<List<User>>();
  Stream<List<User>> get searchStream =>_searchStreamController.stream;

  User _loggedUser;
  User get loggedUser => _loggedUser;

  UserBloc() {
    _authUserStreamSubscription = _userRepository.getAuthUserStream().listen(_handleAuthUserStream);
  }

  _handleAuthUserStream(User authUser) async {
    if (authUser == null) {
      _loggedUser = null;
      return;
    }

    final user = await _userRepository.getByEmail(authUser.email);
    _loggedUser = user;
    _authUserController.sink.add(user);
  }

  Future login(User user, String password) {
    return _userRepository.login(user, password);
  }

  Future logout() => _userRepository.logout();

  Future<User> registerUser(User user, String password) async {
    final createdUser = await _userRepository.createUser(user, password);
    return _userRepository.saveInFirestore(createdUser);
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
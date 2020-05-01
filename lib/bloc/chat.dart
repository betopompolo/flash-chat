import 'package:flash_chat/bloc/user.dart';

class Chat {
  String id;
  List<User> participants;
  final DateTime createAt;
  User loggedUser;

  Chat({
    this.id,
    this.participants,
    this.createAt,
    this.loggedUser,
  });

  get participantsWithoutLoggedUser {
    final participantsClone = List<User>.from(participants);
    participantsClone.removeWhere((participant) => loggedUser.id == participant.id);

    return participantsClone;
  }
}
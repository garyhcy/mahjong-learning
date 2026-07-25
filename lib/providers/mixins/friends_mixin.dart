import 'package:flutter/foundation.dart';

/// Friends management logic, extracted from GameState.
///
/// Mixin holds the friends list in memory (not persisted to SharedPreferences).
/// Achievement checks read `friends.length` via the public getter.
mixin FriendsMixin on ChangeNotifier {
  final List<String> _friends = [];

  /// Unmodifiable view of the current friends list.
  List<String> get friends => List.unmodifiable(_friends);

  void addFriend(String uid) {
    if (!_friends.contains(uid)) {
      _friends.add(uid);
      notifyListeners();
    }
  }

  void removeFriend(String uid) {
    _friends.remove(uid);
    notifyListeners();
  }

  void setFriends(List<String> uids) {
    _friends
      ..clear()
      ..addAll(uids);
    notifyListeners();
  }
}

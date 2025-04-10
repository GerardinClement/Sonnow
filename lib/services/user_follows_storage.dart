import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/models/user.dart';

class UserFollowsStorage {
  static const String followingBoxName = 'following_users';
  static const String followersBoxName = 'followers_users';

  // Initialisation des boxes
  Future<void> initBoxes() async {
    await Hive.openBox(followingBoxName);
    await Hive.openBox(followersBoxName);
  }

  // Méthodes pour les utilisateurs suivis (following)
  Future<void> addFollowing(User user) async {
    final box = Hive.box(followingBoxName);
    await box.put(user.id, true);
  }

  Future<void> removeFollowing(String userId) async {
    final box = Hive.box(followingBoxName);
    await box.delete(userId);
  }

  List<dynamic> getAllFollowing() {
    final box = Hive.box(followingBoxName);
    return box.keys.toList();
  }

  bool isFollowing(String userId) {
    final box = Hive.box(followingBoxName);
    return box.containsKey(userId);
  }

  // Méthodes pour les abonnés (followers)
  Future<void> addFollower(User user) async {
    final box = Hive.box(followersBoxName);
    await box.put(user.id, true);
  }

  Future<void> removeFollower(String userId) async {
    final box = Hive.box(followersBoxName);
    await box.delete(userId);
  }

  List<dynamic> getAllFollowers() {
    final box = Hive.box(followersBoxName);
    return box.keys.toList();
  }
}
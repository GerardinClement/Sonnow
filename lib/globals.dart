import 'package:flutter/material.dart';
import 'package:sonnow/services/user_follows_storage.dart';

final libraryRefreshNotifier = ValueNotifier<bool>(false);
final userProfileRefreshNotifier = ValueNotifier<bool>(false);
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final UserFollowsStorage userFollowsStorage = UserFollowsStorage();

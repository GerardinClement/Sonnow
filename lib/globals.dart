import 'package:flutter/material.dart';
import 'package:sonnow/services/user_follows_storage.dart';
import 'package:sonnow/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final libraryRefreshNotifier = ValueNotifier<bool>(false);
final userProfileRefreshNotifier = ValueNotifier<bool>(false);
final homeRefreshNotifier = ValueNotifier<bool>(false);
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final UserFollowsStorage userFollowsStorage = UserFollowsStorage();
late final String baseUrl;

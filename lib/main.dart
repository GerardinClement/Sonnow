import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/globals.dart';
import 'package:sonnow/app.dart';
import 'package:sonnow/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('liked_releases');
  await Hive.openBox('liked_artists');
  await Hive.openBox('to_listen_releases');
  await Hive.openBox('user_profile');
  userFollowsStorage.initBoxes();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: UniqueKey(),
      title: 'Sonnow',
      theme: AppTheme.lightTheme,
      navigatorObservers: [routeObserver],
      home: App(),
    );
  }
}

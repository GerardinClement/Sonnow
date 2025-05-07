import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonnow/globals.dart';
import 'package:sonnow/app.dart';
import 'package:sonnow/themes/app_theme.dart';
import 'package:sonnow/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  baseUrl = await getBaseUrl();
  await Hive.initFlutter();
  await Hive.openBox('liked_releases');
  await Hive.openBox('liked_artists');
  await Hive.openBox('to_listen_releases');
  await Hive.openBox('user_profile');
  await userFollowsStorage.initBoxes();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: UniqueKey(),
      title: 'Sonnow',
      theme: AppTheme.darkTheme,
      navigatorObservers: [routeObserver],
      home: App(),
    );
  }
}

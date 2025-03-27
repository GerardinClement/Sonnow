import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/pages/welcome_page.dart';
import 'package:sonnow/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('liked_releases');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _homePage = Center(child: CircularProgressIndicator());
  final UserLibraryService userLibraryService = UserLibraryService();
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _getLikedReleases() async {
    final Map<String, String> likedRelease = await userLibraryService.fetchUserLikedReleases();
    await addLikedReleasesInBox(likedRelease);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogin = await AuthService().checkIfLoggedIn();
    if (isLogin) {
      _getLikedReleases();
    }

    setState(() {
      _homePage = isLogin ? HomePage() : WelcomePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Demo')),
        body: _homePage,
      ),
    );
  }
}

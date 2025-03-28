import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonnow/pages/library_page.dart';
import 'package:sonnow/pages/login_page.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/pages/search_page.dart';
import 'package:sonnow/pages/profile_page.dart';
import 'package:sonnow/models/release.dart';
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
  Widget _searchPage = Center(child: CircularProgressIndicator());
  final UserLibraryService userLibraryService = UserLibraryService();
  late bool isLogin = false;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProfilePage(),
    SearchPage(),
    LibraryPage(),
    LoginPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _getLikedReleases() async {
    final List<Release> likedRelease =
        await userLibraryService.fetchUserLikedReleases();
    await addLikedReleasesInBox(likedRelease);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogin = await AuthService().checkIfLoggedIn();
    if (isLogin) {
      _getLikedReleases();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: isLogin ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/home':
            (context) => Scaffold(
              appBar: AppBar(title: Text('Flutter Demo')),
              body: _pages[_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.library_music_rounded),
                    label: 'Library',
                  ),
                ],
              ),
            ),
      },
    );
  }
}

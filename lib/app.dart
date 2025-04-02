import 'package:flutter/material.dart';
import 'package:sonnow/pages/login_page.dart';
import 'package:sonnow/pages/profile_page.dart';
import 'package:sonnow/pages/search_page.dart';
import 'package:sonnow/pages/library_page.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/models/release.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonnow/models/tab_item.dart';
import 'package:sonnow/layouts/bottom_navigation.dart';
import 'package:sonnow/globals.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  final UserLibraryService userLibraryService = UserLibraryService();
  late bool isLogin = false;
  static int currentTab = 0;

  final List<TabItem> tabs = [
    TabItem(
      tabName: "Profile",
      icon: Icons.person,
      page: ProfilePage(),
      index: 0,
    ),
    TabItem(
      tabName: "Search",
      icon: Icons.search,
      page: SearchPage(),
      index: 1,
    ),
    TabItem(
      tabName: "Library",
      icon: Icons.library_music_rounded,
      page: LibraryPage(),
      index: 2,
    ),
  ];

  void _selectTab(int index) {
    if (index == currentTab) {
      tabs[index].key.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => currentTab = index);
    }

    if (tabs[index].tabName == 'Library') {
      libraryRefreshNotifier.value = true;
    }
    else {
      libraryRefreshNotifier.value = false;
    }
  }

  void onLoginSuccess() async {
    await _getLikedReleases();
    await _getToListenReleases();
    setState(() {
      isLogin = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _getLikedReleases() async {
    clearLikedReleasesBox();
    final List<Release> likedRelease = await userLibraryService.fetchUserLikedReleases();
    await addLikedReleasesInBox(likedRelease);
  }

  Future<void> _getToListenReleases() async {
    clearToListenReleasesBox();
    final List<Release> toListenReleases = await userLibraryService.fetchUserToListenReleases();
    await addToListenReleasesInBox(toListenReleases);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogin = await AuthService().checkIfLoggedIn();
    if (isLogin) {
      _getLikedReleases();
      _getToListenReleases();
    }
    setState(() {
      isLogin = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLogin) {
      return LoginPage(
        onLoginSuccess: onLoginSuccess,
      );
    }
    return PopScope(
      child: Scaffold(
        body: IndexedStack(
          index: currentTab,
          children: tabs.map((e) => e.page).toList(),
        ),
        // Bottom navigation
        bottomNavigationBar: BottomNavigation(
          onSelectTab: _selectTab,
          tabs: tabs,
        ),
      ),
    );
  }
}
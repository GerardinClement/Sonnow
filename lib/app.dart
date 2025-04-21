import 'package:flutter/material.dart';
import 'package:sonnow/pages/auth_page.dart';
import 'package:sonnow/pages/profile_page.dart';
import 'package:sonnow/pages/search_page.dart';
import 'package:sonnow/pages/library_page.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:sonnow/services/user_profile_service.dart';
import 'package:sonnow/models/user.dart';
import 'package:sonnow/models/tab_item.dart';
import 'package:sonnow/layouts/bottom_navigation.dart';
import 'package:sonnow/globals.dart';
import 'package:sonnow/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  final UserLibraryService userLibraryService = UserLibraryService();
  final UserProfileService userProfileService = UserProfileService();
  late bool isLogin = false;
  static int currentTab = 0;

  final List<TabItem> tabs = [
    TabItem(
      tabName: "Profile",
      icon: Icons.person,
      page: ProfilePage(user: null),
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
      if (mounted) setState(() => currentTab = index);
    }

    if (tabs[index].tabName == 'Library') {
      libraryRefreshNotifier.value = true;
    } else {
      libraryRefreshNotifier.value = false;
    }
    if (tabs[index].tabName == 'Profile') {
      userProfileRefreshNotifier.value = true;
    } else {
      userProfileRefreshNotifier.value = false;
    }
  }

  void onLoginSuccess() async {
    await _getUserProfile();
    if (mounted) {
      setState(() {
        isLogin = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _getUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final User user = await userProfileService.fetchUserProfile();
    prefs.setString("userId", user.id);
    if (user.highlightRelease != null) {
      await addHighlightReleaseInBox(user.highlightRelease!);
    }
    if (user.highlightArtist != null) {
      await addHighlightArtistInBox(user.highlightArtist!);
    }
    await _getFollowing(user);
    await _getFollowers(user);
    await addLikedArtistsInBox(user.likedArtists);
    await addLikedReleasesInBox(user.likedReleases);
    await addToListenReleasesInBox(user.toListenReleases);
  }

  Future<void> _getFollowing(User user) async {
    for (var follow in user.follows) {
      await userFollowsStorage.addFollowing(follow);
    }
  }

  Future<void> _getFollowers(User user) async {
    for (var follower in user.followers) {
      await userFollowsStorage.addFollower(follower);
    }
  }

  Future<void> _checkLoginStatus() async {
    isLogin = await AuthService().checkIfLoggedIn();
    if (isLogin) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final user = await userProfileService.fetchUserProfile();
      prefs.setString("userId", user.id);
      _getFollowers(user);
      _getFollowing(user);
      await addLikedArtistsInBox(user.likedArtists);
      await addLikedReleasesInBox(user.likedReleases);
      await addToListenReleasesInBox(user.toListenReleases);
    }
    if (mounted) {
      setState(() {
        isLogin = isLogin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home:
          isLogin ? _buildMainApp() : AuthPage(onLoginSuccess: onLoginSuccess),
    );
  }

  Widget _buildMainApp() {
    return PopScope(
      child: Scaffold(
        body: Stack(
          children: [
            // Contenu principal qui s'étend jusqu'au bas de l'écran
            IndexedStack(
              index: currentTab,
              children: tabs.map((e) => e.page).toList(),
            ),

            // Barre de navigation flottante superposée au contenu
            BottomNavigation(
              currentIndex: currentTab,
              onSelectTab: _selectTab,
              tabs: tabs,
            ),
          ],
        ),
      ),
    );
  }
}

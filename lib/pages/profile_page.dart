import 'package:flutter/material.dart';
import 'package:sonnow/services/user_profile_service.dart';
import 'package:sonnow/models/user.dart';
import 'package:sonnow/pages/edit_profile_page.dart';
import 'package:sonnow/pages/settings_page.dart';
import 'package:sonnow/views/artist_card_view.dart';
import 'package:sonnow/views/release_card_view.dart';
import 'package:sonnow/globals.dart';
import 'package:sonnow/views/review_list_view.dart';
import 'package:sonnow/views/user_profile_list_view.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  final UserProfileService userProfileService = UserProfileService();
  late User user;
  late bool editable = false;
  late bool isLoading = true;
  late bool isFollowing = false;

  @override
  initState() {
    super.initState();
    userProfileRefreshNotifier.addListener(_handleTabChange);
    _initializeUser();
  }

  void _initializeUser() {
    if (widget.user != null) {
      setState(() {
        user = widget.user!;
        editable = false;
        isLoading = false;
        isFollowing = userFollowsStorage.isFollowing(user.id);
      });
    } else {
      _fetchUserInfo();
      editable = true;
    }
  }

  void _toggleFollow() {
    if (userFollowsStorage.isFollowing(user.id)) {
      userProfileService.unfollowUser(user);
      userFollowsStorage.removeFollowing(user.id);
    } else {
      userProfileService.followUser(user);
      userFollowsStorage.addFollowing(user);
    }
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (editable) {
      _fetchUserInfo();
    }
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    userProfileRefreshNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (userProfileRefreshNotifier.value && widget.user == null) {
      _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    final fetchedUser = await userProfileService.fetchUserProfile();
    if (mounted) {
      setState(() {
        user = fetchedUser;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          if (editable)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user),
                  ),
                );
              },
            ),
          if (editable)
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => SettingsPage(user: user)));
              },
            ),
          if (!editable)
            IconButton(
              icon: Icon(
                isFollowing
                    ? Icons.add_circle_outlined
                    : Icons.add_circle_outline_outlined,
              ),
              onPressed: () {
                _toggleFollow();
              },
            ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: NetworkImage(user.profilePictureUrl),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => UserProfileListView(
                                      users: user.follows,
                                      shrinkWrap: false,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            "${user.follows.length} Following",
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          ),
                        ),
                        Text("  |  ", style: TextStyle(fontSize: 20)),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => UserProfileListView(
                                      users: user.followers,
                                      shrinkWrap: false,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            "${user.followers.length} Followers",
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        user.bio,
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          user.highlightArtist != null
                              ? ArtistCard(artist: user.highlightArtist!)
                              : SizedBox(height: 8),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          user.highlightRelease != null
                              ? ReleaseCard(release: user.highlightRelease!)
                              : SizedBox(height: 8),
                    ),
                    user.reviews.isNotEmpty
                        ? ReviewListView(
                          reviews: user.reviews,
                          displayReleaseCover: true,
                        )
                        : Text("No reviews yet"),
                  ],
                ),
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sonnow/models/user.dart';
import 'package:sonnow/pages/profile_page.dart';

class UserProfileListView extends StatelessWidget {
  final List<User> users;
  final bool shrinkWrap;

  const UserProfileListView({
    super.key,
    required this.users,
    required this.shrinkWrap,
  });

  @override
  Widget build(BuildContext context) {
    // Lorsqu'utilisé comme page complète
    if (!shrinkWrap) {
      return Scaffold(
        appBar: AppBar(title: const Text('Utilisateurs')),
        body: _buildUsersList(),
      );
    }

    // Lorsqu'utilisé comme composant dans une autre vue
    return _buildUsersList();
  }

  Widget _buildUsersList() {
    return users.isNotEmpty
        ? ListView.builder(
          physics:
              shrinkWrap
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
          shrinkWrap: shrinkWrap,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePictureUrl),
              ),
              title: Text(user.displayName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user),
                  ),
                );
              },
            );
          },
        )
        : const Center(child: Text("No result"));
  }
}

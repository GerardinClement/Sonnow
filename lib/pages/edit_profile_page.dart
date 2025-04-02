import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sonnow/services/user_profile_service.dart';
import 'package:sonnow/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonnow/views/release_card_view.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserProfileService userProfileService = UserProfileService();
  late User user;

  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  late XFile pickedImage;
  late bool isImageEdited = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    pickedImage = XFile(user.profilePictureUrl);
  }

  Future<void> _pickAndUploadProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImageAndUpload(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImageAndUpload(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        isImageEdited = true;
        pickedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCircleAvatar() {
      if (isImageEdited) {
        // Utiliser FileImage pour les images locales
        return CircleAvatar(
          radius: 100,
          backgroundImage: FileImage(File(pickedImage.path)),
        );
      } else {
        // Utiliser NetworkImage pour les URL
        return CircleAvatar(
          radius: 100,
          backgroundImage: NetworkImage(user.profilePictureUrl),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final Map<String, dynamic> updatedUser = {
                'displayName': displayNameController.text,
                'bio': bioController.text,
                'profilePictureUrl': isImageEdited ? pickedImage.path : null,
              };
              await userProfileService.updateUserProfile(updatedUser);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: Column(
            children: [
              InkWell(
                onTap: _pickAndUploadProfileImage,
                child: Stack(
                  children: [
                    buildCircleAvatar(),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.edit,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 0,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: bioController,
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: 'Bio'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonnow/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonnow/utils.dart';

class UserProfileService {
  final String baseUrl = "http://10.0.2.2:8000/profile";

  Future<User> fetchUserProfile() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(Uri.parse("$baseUrl/"), headers: header);

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error getting user profile");
    }
  }

  Future<User> updateUserProfile(Map<String, dynamic> fields) async {
    Map<String, String> header = await setRequestHeader();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse("$baseUrl/"),
    );

    request.headers.addAll(header);
    if (fields['profilePictureUrl'] != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', fields['profilePictureUrl']));
    }
    if (fields['displayName'].isNotEmpty) {
      request.fields['display_name'] = fields['displayName'];
    }

    if (fields['bio'].isNotEmpty) request.fields['bio'] = fields['bio'];

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return User.fromJson(json.decode(responseData));
    } else {
      throw Exception("Error updating user profile image");
    }
  }
}

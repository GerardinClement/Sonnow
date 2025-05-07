import 'package:sonnow/models/user.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/services/user_library_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonnow/utils.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/models/review.dart';
import 'package:sonnow/models/like_artist.dart';
import 'package:sonnow/models/like_release.dart';
import 'package:sonnow/globals.dart';

class UserProfileService {
  String url = "$baseUrl/profile";
  final UserLibraryService userLibraryService = UserLibraryService();

  Future<User> fetchUserProfile() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(Uri.parse("$url/"), headers: header);

    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      return User.fromJson(json.decode(responseData));
    } else {
      throw Exception("Error getting user profile");
    }
  }

  Future<User> getUserProfile(String userId) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$url/$userId/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      return User.fromJson(json.decode(responseData));
    } else {
      throw Exception("Error getting user profile");
    }
  }

  Future<List<User>> searchUser(String query) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$url/search/?q=$query"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as List;
      return responseData.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception("Error searching user");
    }
  }

  Future<void> followUser(User user) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.post(
      Uri.parse("$url/follow/${user.id}/"),
      headers: header,
    );

    if (response.statusCode != 200) {
      throw Exception("Error following user");
    }
  }

  Future<void> unfollowUser(User user) async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.delete(
      Uri.parse("$url/unfollow/${user.id}/"),
      headers: header,
    );

    if (response.statusCode != 200) {
      throw Exception("Error unfollowing user");
    }
  }

  Future<User> updateUserProfile(Map<String, dynamic> fields) async {
    Map<String, String> header = await setRequestHeader();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse("$url/"),
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

  Future<void> setHighlightedArtist(Artist artist) async {
    Map<String, String> header = await setRequestHeader();

    await userLibraryService.getOrCreateArtist(artist);
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse("$url/"),
    );

    request.headers.addAll(header);
    request.fields['highlighted_artist_id'] = artist.id;
    final response = await request.send();

    if (response.statusCode == 200) {
      await addHighlightArtistInBox(artist);
    } else {
      throw Exception("Error setting highlighted artist");
    }
  }

  Future<void> setHighlightedRelease(Release release) async {
    Map<String, String> header = await setRequestHeader();

    await userLibraryService.getOrCreateRelease(release);
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse("$url/"),
    );

    request.headers.addAll(header);
    request.fields['highlighted_release_id'] = release.id;
    final response = await request.send();

    if (response.statusCode == 200) {
      await addHighlightReleaseInBox(release);
    } else {
      throw Exception("Error setting highlighted release");
    }
  }

  Future<List<Review>>  getFollowedReviews() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$url/followed-reviews/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      final responseList = json.decode(responseData) as List;
      return responseList.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception("Error getting followers reviews");
    }
  }

  Future<List<LikeRelease>> getFollowedLikedReleases() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$url/followed-liked-releases/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      final responseList = json.decode(responseData) as List;
      return responseList.map((json) => LikeRelease.fromJson(json)).toList();
    } else {
      throw Exception("Error getting followers liked releases");
    }
  }

  Future<List<LikeArtist>> getFollowedLikedArtists() async {
    Map<String, String> header = await setRequestHeader();

    final response = await http.get(
      Uri.parse("$url/followed-liked-artists/"),
      headers: header,
    );

    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      final responseList = json.decode(responseData) as List;
      if (responseList.isEmpty) return [];
      return responseList.map((json) => LikeArtist.fromJson(json)).toList();
    } else {
      throw Exception("Error getting followers liked artists");
    }
  }
}

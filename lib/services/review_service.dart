import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sonnow/models/review.dart';
import 'package:sonnow/models/release.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/services/user_library_service.dart';
import 'package:sonnow/utils.dart';

class ReviewService {
  final AuthService authService = AuthService();
  final UserLibraryService userLibraryService = UserLibraryService();
  final String baseUrl = "http://10.0.2.2:8000/review";

  Future<List<Review>> getReviews(String releaseId) async {
    final response = await http.get(Uri.parse("$baseUrl/$releaseId/"));

    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      List<Review> reviews = (json.decode(responseData) as List)
          .map((review) => Review.fromJson(review))
          .toList();

      return reviews;
    } else {
      throw Exception("Error getting reviews");
    }
  }

  Future<Review> postReview(Release release, String content, Map<int, String> tags) async {
    final header = await setRequestHeader();

    await userLibraryService.getOrCreateRelease(release);
    final response = await http.post(
      Uri.parse("$baseUrl/"),
      headers: header,
      body: jsonEncode({
        "content": content,
        "tag_ids": tags.keys.toList(),
        "release_id": release.id,
      }),
    );

    if (response.statusCode == 201) {
      return Review.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error posting review");
    }
  }

  Future<Map<int, String>> getAllTags() async {
    final response = await http.get(Uri.parse("$baseUrl/tags/"));

    if (response.statusCode == 200) {
      Map<int, String> tags = {};
      List<dynamic> data = json.decode(response.body);
      for (var item in data) {
        tags[item['id']] = item['content'];
      }
      return tags;
    } else {
      throw Exception("Error getting tags");
    }
  }

  Future<ReviewReaction?> reactToReview(Review review, String emoji) async {
    final header = await setRequestHeader();

    final response = await http.post(
      Uri.parse("$baseUrl/${review.id}/react/"),
      headers: header,
      body: jsonEncode({
        "emoji": emoji,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = utf8.decode(response.bodyBytes);
      return ReviewReaction.fromJson(json.decode(responseData));
    } else {
      throw Exception("Error reacting to review");
    }
  }

  Future<bool> deleteReactToReview(Review review, ReviewReaction reaction) async {
    final header = await setRequestHeader();

    final response = await http.delete(
      Uri.parse("$baseUrl/${review.id}/react/${reaction.id}/"),
      headers: header,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception("Error deleting reaction to review");
    }
  }

}
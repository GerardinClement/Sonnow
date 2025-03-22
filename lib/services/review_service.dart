import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sonnow/models/review.dart';
import 'package:sonnow/services/auth_service.dart';

class ReviewService {
  final AuthService authService = AuthService();
  final String baseUrl = "http://10.0.2.2:8000/review";

  Future<List<Review>> getReviews(String releaseId) async {
    final response = await http.get(Uri.parse("$baseUrl/$releaseId"));

    if (response.statusCode == 200) {
      List<Review> reviews = (json.decode(response.body) as List)
          .map((review) => Review.fromJson(review))
          .toList();

      return reviews;
    } else {
      throw Exception("Error getting reviews");
    }
  }

  Future<Review> postReview(String releaseId, String content, double rating) async {
    if (!await authService.checkIfLoggedIn()) throw Exception("User not logged in");

    final csrfToken = await authService.getCsrfToken();
    final token = await authService.getToken("access_token");

    if (token == null) return throw Exception("Error with access token"); // TODO: Handle this case
    final response = await http.post(
      Uri.parse("$baseUrl/$releaseId/create/"),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
        "Authorization": "Bearer $token",
        "Cookie": "csrftoken=$csrfToken",
      },
      body: jsonEncode({
        "content": content,
        "rating": rating,
      }),
    );

    if (response.statusCode == 201) {
      return Review.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error posting review");
    }
  }

}
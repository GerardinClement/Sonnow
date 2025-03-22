class Review {
  final String releaseId;
  final String content;
  final double rating;
  final String user;
  final String date;

  Review({
    required this.releaseId,
    required this.content,
    required this.rating,
    required this.user,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      releaseId: json['release_id']?.toString() ?? "Unknown",
      content: json['content']?.toString() ?? "Unknown",
      rating: (json['rating'] is String) ? double.parse(json['rating']) : json['rating'].toDouble(),
      user: json['user']?.toString() ?? "Unknown",
      date: json['date']?.toString() ?? "Unknown",
    );
  }
}
class Track {
  final String id;
  final String title;
  final String artist;
  final String date;
  final int position;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.date,
    required this.position,
  });

  factory Track.fromJson(Map<String, dynamic> json, String artistName) {
    return Track(
      id: json['id']?.toString() ?? "Unknown",
      title: json['title']?.toString() ?? "Unknown",
      artist: artistName,
      date: json['date']?.toString() ?? "Unknown",
      position: json['position'] ?? 0,

    );
  }
}
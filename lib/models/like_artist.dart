import 'package:flutter/material.dart';
import 'package:sonnow/models/artist.dart';
import 'package:sonnow/models/user.dart';

class LikeArtist {
  final String id;
  final Artist artist;
  final User user;
  final DateTime createdAt;

  LikeArtist({
    required this.id,
    required this.artist,
    required this.user,
    required this.createdAt,
  });

  factory LikeArtist.fromJson(Map<String, dynamic> json) {
    return LikeArtist(
      id: json['id']?.toString() ?? "Unknown",
      artist: Artist.fromJson(json['artist']),
      user: User.fromJson(json['user']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }
}
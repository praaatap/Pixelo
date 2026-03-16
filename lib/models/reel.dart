import 'user.dart';

class Reel {
  final String id;
  final User user;
  final String imageUrl; // For vertical mock backgrounds
  final String caption;
  final String likes;
  final String comments;
  final bool isLiked;

  Reel({
    required this.id,
    required this.user,
    required this.imageUrl,
    required this.caption,
    this.likes = '0',
    this.comments = '0',
    this.isLiked = false,
  });

  Reel copyWith({
    String? id,
    User? user,
    String? imageUrl,
    String? caption,
    String? likes,
    String? comments,
    bool? isLiked,
  }) {
    return Reel(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

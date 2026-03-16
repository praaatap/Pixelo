import 'user.dart';

class Post {
  final String id;
  final User user;
  final List<String> imageUrls;
  final int likes;
  final int comments;
  final String caption;
  final String timeAgo;
  final bool isLiked;
  final bool isSaved;

  Post({
    required this.id,
    required this.user,
    required this.imageUrls,
    required this.likes,
    required this.comments,
    required this.caption,
    required this.timeAgo,
    this.isLiked = false,
    this.isSaved = false,
  });

  Post copyWith({
    String? id,
    User? user,
    List<String>? imageUrls,
    int? likes,
    int? comments,
    String? caption,
    String? timeAgo,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      caption: caption ?? this.caption,
      timeAgo: timeAgo ?? this.timeAgo,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

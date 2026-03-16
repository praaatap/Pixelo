class User {
  final String id;
  final String username;
  final String profileImageUrl;
  final String bio;
  final String posts;
  final String followers;
  final String following;

  User({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    this.bio = '',
    this.posts = '0',
    this.followers = '0',
    this.following = '0',
  });

  User copyWith({
    String? id,
    String? username,
    String? profileImageUrl,
    String? bio,
    String? posts,
    String? followers,
    String? following,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      posts: posts ?? this.posts,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}

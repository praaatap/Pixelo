import 'user.dart';

class Story {
  final String id;
  final User user;
  final bool hasUnseenStory;

  Story({
    required this.id,
    required this.user,
    this.hasUnseenStory = true,
  });
}

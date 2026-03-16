import 'package:flutter_riverpod/legacy.dart';

import '../models/user.dart';

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
    : super(
        User(
          id: '1',
          username: 'madx',
          profileImageUrl:
              'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&q=80&w=150',
          bio:
              'Software Engineer \nFlutter Enthusiast 📱\nBuilding cool stuff ✨',
          posts: '12',
          followers: '1.2M',
          following: '345',
        ),
      );

  void updateBio(String newBio) {
    state = state.copyWith(bio: newBio);
  }

  void updateUsername(String newUsername) {
    state = state.copyWith(username: newUsername);
  }
}

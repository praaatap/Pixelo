import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import 'post_repository_provider.dart';

final storiesProvider = FutureProvider<List<Story>>((ref) async {
  final repo = ref.read(postRepositoryProvider);
  return repo.fetchStories();
});

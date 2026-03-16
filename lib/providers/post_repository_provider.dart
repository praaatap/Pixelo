import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

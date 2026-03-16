import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import 'post_repository_provider.dart';

@immutable
class ExploreFeedState {
  const ExploreFeedState({
    required this.posts,
    required this.hasMore,
    required this.isLoadingMore,
    this.error,
  });

  final List<Post> posts;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;

  ExploreFeedState copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isLoadingMore,
    String? error,
  }) {
    return ExploreFeedState(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final exploreProvider = AsyncNotifierProvider<ExploreNotifier, ExploreFeedState>(
  ExploreNotifier.new,
);

class ExploreNotifier extends AsyncNotifier<ExploreFeedState> {
  static const int _limit = 18; // 3x6 grid roughly

  int _page = 0;

  @override
  Future<ExploreFeedState> build() async {
    _page = 0;
    final repo = ref.watch(postRepositoryProvider);
    // Initial fetch
    final posts = await repo.fetchExplorePosts(page: _page, limit: _limit);

    return ExploreFeedState(
      posts: posts,
      hasMore: true, // Infinite scroll simulation
      isLoadingMore: false,
    );
  }

  Future<void> fetchMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true, error: null));

    final repo = ref.read(postRepositoryProvider);
    final nextPage = _page + 1;

    try {
      final newPosts = await repo.fetchExplorePosts(page: nextPage, limit: _limit);
      final freshState = state.value ?? currentState;

      state = AsyncData(
        freshState.copyWith(
          posts: [...freshState.posts, ...newPosts],
          hasMore: true, // Infinite simulation
          isLoadingMore: false,
        ),
      );

      _page = nextPage;
    } catch (error, stackTrace) {
      debugPrint('ExploreNotifier.fetchMore failed: $error\n$stackTrace');
      state = AsyncData(currentState.copyWith(isLoadingMore: false, error: error.toString()));
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../services/local_storage_service.dart';
import 'post_repository_provider.dart';

@immutable
class PostsFeedState {
  const PostsFeedState({
    required this.posts,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<Post> posts;
  final bool hasMore;
  final bool isLoadingMore;

  PostsFeedState copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PostsFeedState(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, PostsFeedState>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<PostsFeedState> {
  static const int _limit = 10;

  int _page = 0;

  @override
  Future<PostsFeedState> build() async {
    _page = 0;
    final repo = ref.watch(postRepositoryProvider);
    var posts = await repo.fetchPosts(page: _page, limit: _limit);

    // Load persisted likes and saves from local storage
    final likedPostIds = await LocalStorageService.getLikedPostIds();
    final savedPostIds = await LocalStorageService.getSavedPostIds();

    // Reconstruct posts with persisted state
    posts = posts
        .map((post) => post.copyWith(
              isLiked: likedPostIds.contains(post.id),
              isSaved: savedPostIds.contains(post.id),
            ))
        .toList();

    return PostsFeedState(
      posts: posts,
      hasMore: posts.length == _limit,
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

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    final repo = ref.read(postRepositoryProvider);
    final nextPage = _page + 1;

    try {
      final newPosts = await repo.fetchPosts(page: nextPage, limit: _limit);
      final freshState = state.value ?? currentState;

      state = AsyncData(
        freshState.copyWith(
          posts: [...freshState.posts, ...newPosts],
          hasMore: newPosts.length == _limit,
          isLoadingMore: false,
        ),
      );

      if (newPosts.isNotEmpty) {
        _page = nextPage;
      }
    } catch (error, stackTrace) {
      debugPrint('PostsNotifier.fetchMore failed: $error\n$stackTrace');
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  void toggleLike(String postId) {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final newPost = currentState.posts.firstWhere((p) => p.id == postId);
    final isCurrentlyLiked = newPost.isLiked;

    state = AsyncData(
      currentState.copyWith(
        posts: currentState.posts
            .map((post) {
              if (post.id != postId) {
                return post;
              }

              return post.copyWith(
                isLiked: !post.isLiked,
                likes: post.isLiked ? post.likes - 1 : post.likes + 1,
              );
            })
            .toList(growable: false),
      ),
    );

    // Persist to local storage
    if (isCurrentlyLiked) {
      LocalStorageService.removeLikedPostId(postId);
    } else {
      LocalStorageService.saveLikedPostId(postId);
    }
  }

  void toggleSave(String postId) {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final newPost = currentState.posts.firstWhere((p) => p.id == postId);
    final isCurrentlySaved = newPost.isSaved;

    state = AsyncData(
      currentState.copyWith(
        posts: currentState.posts
            .map((post) {
              if (post.id != postId) {
                return post;
              }

              return post.copyWith(isSaved: !post.isSaved);
            })
            .toList(growable: false),
      ),
    );

    // Persist to local storage
    if (isCurrentlySaved) {
      LocalStorageService.removeSavedPostId(postId);
    } else {
      LocalStorageService.saveSavedPostId(postId);
    }
  }
}

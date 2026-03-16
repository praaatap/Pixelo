import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reel.dart';
import 'post_repository_provider.dart';

final reelsProvider = AsyncNotifierProvider<ReelsNotifier, List<Reel>>(
  ReelsNotifier.new,
);

class ReelsNotifier extends AsyncNotifier<List<Reel>> {
  int _page = 0;
  final int _limit = 5;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<Reel>> build() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    // ✅ ref.watch inside build()
    final repo = ref.watch(postRepositoryProvider);
    return await repo.fetchReels(page: _page, limit: _limit);
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || state.isLoading || state.hasError || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    final repo = ref.read(postRepositoryProvider);

    try {
      _page++;
      final newReels = await repo.fetchReels(page: _page, limit: _limit);

      if (newReels.isEmpty) {
        _hasMore = false;
      } else {
        // ✅ Re-read state after await — preserves mid-flight toggles
        final freshReels = state.value ?? [];
        state = AsyncData([...freshReels, ...newReels]);
      }
    } catch (e, st) {
      _page--; // ✅ Rollback on failure
      debugPrint('ReelsNotifier.fetchMore error: $e\n$st');
    } finally {
      _isLoadingMore = false;
    }
  }

  void toggleLike(String reelId) {
    if (state.value == null) return;
    state = AsyncData(
      state.value!.map((reel) {
        if (reel.id != reelId) return reel;
        
        // Try to update like count if it's a simple number
        String newLikes = reel.likes;
        try {
          // Remove commas or k/M if necessary, but here we assume simple numbers for now
          // or just parse if possible.
          if (RegExp(r'^\d+$').hasMatch(reel.likes)) {
             int count = int.parse(reel.likes);
             count = !reel.isLiked ? count + 1 : count - 1;
             newLikes = count.toString();
          }
        } catch (_) {}

        return reel.copyWith(isLiked: !reel.isLiked, likes: newLikes);
      }).toList(),
    );
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}

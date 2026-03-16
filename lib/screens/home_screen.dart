import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/posts_provider.dart';
import '../providers/stories_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_shimmer.dart';
import '../widgets/stories_shimmer.dart';
import '../widgets/stories_tray.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double _paginationTriggerExtent = 1200;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter <= _paginationTriggerExtent) {
      ref.read(postsProvider.notifier).fetchMore();
    }
  }

  Future<void> _refreshFeed() {
    return Future.wait([
      ref.refresh(postsProvider.future),
      ref.refresh(storiesProvider.future),
    ]);
  }

  void _showUnimplementedSnackbar(String label) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text(
          '$label is not implemented in this demo.',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final storiesState = ref.watch(storiesProvider);
    final currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Instagram',
          style: GoogleFonts.grandHotel(
            fontSize: 34,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.heart, size: 24),
            onPressed: () => _showUnimplementedSnackbar('Notifications'),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.chat_bubble_text, size: 24),
            onPressed: () => _showUnimplementedSnackbar('Direct messages'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: _refreshFeed,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Stories
            SliverToBoxAdapter(
              child: storiesState.when(
                data: (stories) =>
                    StoriesTray(stories: stories, currentUser: currentUser),
                loading: () => const StoriesShimmer(),
                error: (error, stackTrace) {
                  return const SizedBox(
                    height: 104,
                    child: Center(child: Text('Unable to load stories')),
                  );
                },
              ),
            ),
            // Posts with search filtering
            postsState.when(
              data: (feedState) {
                final filteredPosts = feedState.posts;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= filteredPosts.length) {
                        return const PostPaginationShimmer();
                      }

                      return PostCard(post: filteredPosts[index]);
                    },
                    childCount:
                        filteredPosts.length +
                        (feedState.isLoadingMore ? 1 : 0),
                  ),
                );
              },
              loading: () {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const PostShimmer(),
                    childCount: 3,
                  ),
                );
              },
              error: (error, stackTrace) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Unable to load the feed right now.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
  
    );
  }
}

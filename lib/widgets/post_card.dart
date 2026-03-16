import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../screens/post_detail_screen.dart';
import '../utils/ui_constants.dart';
import 'pinch_to_zoom.dart';
import 'post_action_bar.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;

  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartFadeAnimation;
  bool _isHeartAnimating = false;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: UIConstants.heartAnimationDuration,
    );

    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 50,
      ),
    ]).animate(_heartAnimationController);

    _heartFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_heartAnimationController);

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isHeartAnimating = false;
        });
        _heartAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _triggerHeartAnimation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isHeartAnimating = true;
    });
    _heartAnimationController.forward();
    if (!widget.post.isLiked) {
      ref.read(postsProvider.notifier).toggleLike(widget.post.id);
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PostDetailScreen(post: widget.post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showUnimplementedSnackbar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action is not implemented in this demo.',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageSize = MediaQuery.of(context).size.width;
    final cacheWidth = (imageSize * MediaQuery.of(context).devicePixelRatio)
        .round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.postHeaderPadding,
            vertical: 8,
          ),
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${widget.post.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pink, Colors.orange],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: CachedNetworkImageProvider(
                            widget.post.user.profileImageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.user.username,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(CupertinoIcons.ellipsis, size: 20),
                onPressed: () =>
                    _showUnimplementedSnackbar(context, 'Post Options'),
              ),
            ],
          ),
        ),
        GestureDetector(
          onDoubleTap: _triggerHeartAnimation,
          onTap: _navigateToDetail,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PinchToZoomImage(
                child: SizedBox(
                  width: double.infinity,
                  height: imageSize,
                  child: PageView.builder(
                    itemCount: widget.post.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0
                            ? widget.post.imageUrls[0]
                            : 'image_${widget.post.id}_$index',
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrls[index],
                          fit: BoxFit.cover,
                          memCacheWidth: cacheWidth,
                          maxWidthDiskCache: cacheWidth,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: (context, url) => Container(
                            color: isDark ? Colors.grey[900] : Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: isDark ? Colors.grey[900] : Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.wifi_exclamationmark,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Multi-image indicator (top-right)
              if (widget.post.imageUrls.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.square_on_square,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_currentImageIndex + 1}/${widget.post.imageUrls.length}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Like animation
              if (_isHeartAnimating)
                FadeTransition(
                  opacity: _heartFadeAnimation,
                  child: ScaleTransition(
                    scale: _heartScaleAnimation,
                    child: const Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.white,
                      size: 100,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        PostActionBar(
          post: widget.post,
          isDark: isDark,
          currentImageIndex: _currentImageIndex,
          onLike: () {
            HapticFeedback.lightImpact();
            ref.read(postsProvider.notifier).toggleLike(widget.post.id);
          },
          onSave: () =>
              ref.read(postsProvider.notifier).toggleSave(widget.post.id),
          onUnimplemented: (action) =>
              _showUnimplementedSnackbar(context, action),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.postContentPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated like count
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '${widget.post.likes} likes',
                  key: ValueKey<int>(widget.post.likes),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                    height: 1.25,
                  ),
                  children: [
                    TextSpan(
                      text: widget.post.user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  _showUnimplementedSnackbar(context, 'Comments');
                },
                child: Text(
                  'View all ${widget.post.comments} comments',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.post.timeAgo} ago',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

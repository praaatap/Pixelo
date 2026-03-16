import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';

class PostActionBar extends StatefulWidget {
  final Post post;
  final bool isDark;
  final int currentImageIndex;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final Function(String) onUnimplemented;

  const PostActionBar({
    super.key,
    required this.post,
    required this.isDark,
    required this.currentImageIndex,
    required this.onLike,
    required this.onSave,
    required this.onUnimplemented,
  });

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  late AnimationController _saveAnimationController;
  late Animation<double> _saveScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Like button animation
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInBack)),
        weight: 50,
      ),
    ]).animate(_likeAnimationController);

    // Save button animation
    _saveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _saveScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInBack)),
        weight: 50,
      ),
    ]).animate(_saveAnimationController);
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    _likeAnimationController.forward(from: 0.0);
    widget.onLike();
  }

  void _handleSaveTap() {
    _saveAnimationController.forward(from: 0.0);
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          // Like button with scale animation
          ScaleTransition(
            scale: _likeScaleAnimation,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              splashRadius: 22,
              onPressed: _handleLikeTap,
              icon: Icon(
                widget.post.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: widget.post.isLiked
                    ? Colors.red
                    : (widget.isDark ? Colors.white : Colors.black),
                size: 28,
              ),
            ),
          ),
          // Comments with count badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                splashRadius: 22,
                onPressed: () => widget.onUnimplemented('Comments'),
                icon: const Icon(CupertinoIcons.chat_bubble, size: 25),
              ),
              if (widget.post.comments > 0)
                Positioned(
                  right: 2,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0095F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.post.comments.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            splashRadius: 22,
            onPressed: () => widget.onUnimplemented('Sharing'),
            icon: const Icon(CupertinoIcons.paperplane, size: 24),
          ),
          Expanded(
            child: Center(
              child: widget.post.imageUrls.length > 1
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        widget.post.imageUrls.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.currentImageIndex == index
                                ? const Color(0xFF0095F6)
                                : Colors.grey.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Save button with scale animation
          ScaleTransition(
            scale: _saveScaleAnimation,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              splashRadius: 22,
              onPressed: _handleSaveTap,
              icon: Icon(
                widget.post.isSaved
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                color: widget.post.isSaved
                    ? (widget.isDark ? Colors.yellowAccent : Colors.amber) // Changed color when saved as requested
                    : (widget.isDark ? Colors.white : Colors.black),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

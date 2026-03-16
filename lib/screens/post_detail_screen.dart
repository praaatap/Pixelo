import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../widgets/pinch_to_zoom.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartFadeAnimation;
  bool _isHeartAnimating = false;

  // Entrance Animations
  late AnimationController _entranceController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _imageFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _commentFade;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;

    // Heart Animation Setup
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartAnimationController);

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isHeartAnimating = false;
        });
        _heartAnimationController.reset();
      }
    });

    // Entrance Animation Setup
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutExpo),
          ),
        );

    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _commentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _triggerHeartAnimation() {
    setState(() {
      _isHeartAnimating = true;
      _isLiked = true;
    });
    _heartAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Post',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            SlideTransition(
              position: _headerSlide,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'avatar_${widget.post.id}',
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.pink, Colors.orange],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.post.user.profileImageUrl,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.user.username,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Original Audio',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz),
                  ],
                ),
              ),
            ),

            // Image with Carousel and Double Tap
            FadeTransition(
              opacity: _imageFade,
              child: GestureDetector(
                onDoubleTap: _triggerHeartAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                        itemCount: widget.post.imageUrls.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          return PinchToZoomImage(
                            child: Hero(
                              tag: index == 0
                                  ? widget.post.imageUrls[0]
                                  : 'image_${widget.post.id}_$index',
                              child: CachedNetworkImage(
                                imageUrl: widget.post.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: isDark
                                      ? Colors.grey[900]
                                      : Colors.grey[200],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Indicators
                    if (widget.post.imageUrls.length > 1)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${widget.post.imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

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
            ),

            // Interaction Buttons
            SlideTransition(
              position: _contentSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        AnimatedScale(
                          scale: _isLiked ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            icon: Icon(
                              _isLiked
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              size: 28,
                              color: _isLiked
                                  ? Colors.red
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                            onPressed: () =>
                                setState(() => _isLiked = !_isLiked),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.chat_bubble,
                            size: 26,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.paperplane, size: 26),
                          onPressed: () {},
                        ),
                        const Spacer(),
                        if (widget.post.imageUrls.length > 1)
                          Row(
                            children: widget.post.imageUrls.asMap().entries.map(
                              (entry) {
                                return Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == entry.key
                                        ? Colors.blue
                                        : Colors.grey.withValues(alpha: 0.5),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(CupertinoIcons.bookmark, size: 26),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Likes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_isLiked ? widget.post.likes + 1 : widget.post.likes} likes',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Caption
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.post.user.username} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: widget.post.caption),
                        ],
                      ),
                    ),
                  ),

                  // Time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.post.timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(thickness: 0.5),
                  ),

                  // Comments Entrance
                  FadeTransition(
                    opacity: _commentFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comments',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const CommentItem(
                            username: 'aesthetic_queen',
                            comment: 'Wow, this looks amazing! 😍',
                            time: '1h',
                            avatar:
                                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?fit=crop&w=50',
                          ),
                          const CommentItem(
                            username: 'nature_lover',
                            comment: 'Love the colors here! ✨',
                            time: '2h',
                            avatar:
                                'https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43?fit=crop&w=50',
                          ),
                          const CommentItem(
                            username: 'alex_photo',
                            comment: 'Great shot! What camera did you use? 📸',
                            time: '3h',
                            avatar:
                                'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?fit=crop&w=50',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final String username;
  final String comment;
  final String time;
  final String avatar;

  const CommentItem({
    super.key,
    required this.username,
    required this.comment,
    required this.time,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: CachedNetworkImageProvider(avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '$username ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.heart, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

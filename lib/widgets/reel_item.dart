import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/reel.dart';
import '../providers/reels_provider.dart';
import 'pinch_to_zoom.dart';

class ReelItem extends ConsumerStatefulWidget {
  final Reel reel;

  const ReelItem({super.key, required this.reel});

  @override
  ConsumerState<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends ConsumerState<ReelItem> with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  bool _isHeartAnimating = false;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _heartAnimationController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _isHeartAnimating = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!_isHeartAnimating) {
      setState(() {
        _isHeartAnimating = true;
      });
      _heartAnimationController.forward();
      
      if (!widget.reel.isLiked) {
        ref.read(reelsProvider.notifier).toggleLike(widget.reel.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Video/Image with Pinch to Zoom & Double Tap
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: PinchToZoomImage(
            child: CachedNetworkImage(
              imageUrl: reel.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Gradient Overlay for visibility
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),

        // Big Heart Animation Overlay
        if (_isHeartAnimating)
          Center(
            child: ScaleTransition(
              scale: _heartScaleAnimation,
              child: const Icon(
                CupertinoIcons.heart_fill,
                color: Colors.white, // Usually white or red with transparency
                size: 100,
              ),
            ),
          ),

        // Overlay actions
        Positioned(
          right: 15,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReelAction(
                reel.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart, 
                reel.likes,
                color: reel.isLiked ? Colors.red : Colors.white,
                onTap: () => ref.read(reelsProvider.notifier).toggleLike(reel.id),
              ),
              const SizedBox(height: 20),
              _buildReelAction(CupertinoIcons.chat_bubble, reel.comments),
              const SizedBox(height: 20),
              _buildReelAction(CupertinoIcons.paperplane, 'Share'),
              const SizedBox(height: 20),
              const Icon(Icons.more_vert, color: Colors.white, size: 30),
              const SizedBox(height: 20),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(reel.user.profileImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Info Overlay
        Positioned(
          left: 15,
          bottom: 20,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(reel.user.profileImageUrl),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    reel.user.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Follow', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                reel.caption,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(CupertinoIcons.music_note, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text('Original Audio', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReelAction(IconData icon, String label, {Color color = Colors.white, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import '../models/post.dart';
import '../models/story.dart';
import '../models/user.dart';
import '../models/reel.dart';

class PostRepository {
  // Simulating a database of posts
  static final List<Story> _allStories = _generateMockStories();

  Future<List<Post>> fetchPosts({int page = 0, int limit = 10}) async {
    // Simulate network latency (1.0 seconds for smoother feel)
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return _generatePosts(page, limit);
  }

  /// Technical Requirement: Returns a Stream or Future
  Stream<List<Post>> streamPosts({int page = 0, int limit = 10}) async* {
    yield* Stream.fromFuture(fetchPosts(page: page, limit: limit));
  }

  Future<List<Reel>> fetchReels({int page = 0, int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final startIndex = page * limit;
    final List<Reel> reels = [];
    final Random rnd = Random();

    for (int i = 0; i < limit; i++) {
      final user = _mockUsers[rnd.nextInt(_mockUsers.length)];
      final image = _mockReelImages[rnd.nextInt(_mockReelImages.length)];
      reels.add(Reel(
        id: 'reel_${startIndex + i}',
        user: user,
        imageUrl: image,
        caption: 'This is a vertical reel ${startIndex + i}! #reels #viral',
        likes: '${rnd.nextInt(500) + 1}k',
        comments: '${rnd.nextInt(100) + 1}k',
      ));
    }
    return reels;
  }
  
  Future<List<Story>> fetchStories() async {
     await Future.delayed(const Duration(milliseconds: 500));
     return _allStories;
  }

  static List<Story> _generateMockStories() {
    return _mockUsers.skip(1).map((user) => Story(id: 'story_${user.id}', user: user)).toList();
  }

  List<Post> _generatePosts(int page, int limit) {
    final List<Post> posts = [];
    final startIndex = page * limit;
    final Random rnd = Random(page * 1000); // Deterministic seed per page
    
    const captions = [
      'golden hour, clean lines, and a camera roll full of keepers.',
      'weekend uniform. coffee first, everything else later.',
      'new drop, same obsession with texture and light.',
      'city frames that felt too good to leave in drafts.',
      'soft tones, sharp shadows, and one perfect corner.',
      'kept this one simple and let the color do the work.',
      'a little motion blur makes it feel more honest.',
      'moodboard energy, but real life this time.',
      'caught this moment between chaos and calm.',
      'colors that don’t need a filter.',
    ];
    
    for (int i = 0; i < limit; i++) {
        final index = startIndex + i;
        final user = _mockUsers[rnd.nextInt(_mockUsers.length)]; 
        final numImages = rnd.nextInt(3) + 1; 
        final List<String> images = [];
        
        // Generate unique images using picsum seeds based on post index
        for (int j = 0; j < numImages; j++) {
            // Use picsum for unique reliable images
            images.add('https://picsum.photos/seed/pixelo_${index}_$j/800/1000');
        }
        
        posts.add(Post(
            id: 'post_$index',
            user: user,
            imageUrls: images,
            likes: rnd.nextInt(9500) + 120,
            comments: rnd.nextInt(150) + 5,
            caption: '${captions[index % captions.length]} #style #photo #daily',
            timeAgo: '${rnd.nextInt(23) + 1}h',
        ));
    }
    return posts;
  }

  Future<List<Post>> fetchExplorePosts({int page = 0, int limit = 18}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final List<Post> posts = [];
    final Random rnd = Random(page * 2000); 
    
    // Original list from ExploreScreen + more
    const exploreImages = [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1502673530728-f79b4cab31b1?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1529139513055-1191928c611f?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1506634572416-48cdfe530110?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1523264629844-40dd6bf17c2b?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1536766768598-e09213fdcf22?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1621784563330-cae22797e8ec?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1531123414780-f74242c2b052?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=400',
    ];

    for (int i = 0; i < limit; i++) {
        final index = (page * limit) + i;
        final user = _mockUsers[rnd.nextInt(_mockUsers.length)];
        // Use modulo to cycle through images but with random starting point per page
        final imageIndex = index % exploreImages.length;
        final imageUrl = exploreImages[imageIndex];

        posts.add(Post(
            id: 'explore_$index',
            user: user,
            imageUrls: [imageUrl],
            likes: rnd.nextInt(5000) + 100,
            comments: rnd.nextInt(100) + 10,
            caption: 'Discovering new perspectives. #explore #vibes',
            timeAgo: '${rnd.nextInt(23) + 1}h',
        ));
    }
    return posts;
  }
}

// Mock Data Resources
final List<User> _mockUsers = [
  User(id: 'u0', username: 'current_user', profileImageUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&q=80&w=150'),
  User(id: 'u1', username: 'alex_fashion', profileImageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=150'),
  User(id: 'u2', username: 'sarah_styles', profileImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150'),
  User(id: 'u3', username: 'mike_trends', profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150'),
  User(id: 'u4', username: 'lily_vibe', profileImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150'),
  User(id: 'u5', username: 'james_look', profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150'),
  User(id: 'u6', username: 'jess_art', profileImageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=150'),
];

final List<String> _mockReelImages = [
  'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&h=1600&w=900',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&h=1600&w=900',
  'https://images.unsplash.com/photo-1502673530728-f79b4cab31b1?auto=format&fit=crop&q=80&h=1600&w=900',
  'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&q=80&h=1600&w=900',
  'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&h=1600&w=900',
  'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&q=80&h=1600&w=900',
];

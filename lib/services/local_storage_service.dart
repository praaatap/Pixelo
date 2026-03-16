import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _savedPostsKey = 'saved_posts';
  static const String _likedPostsKey = 'liked_posts';

  static Future<void> saveSavedPostId(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosts = prefs.getStringList(_savedPostsKey) ?? [];
    
    if (!savedPosts.contains(postId)) {
      savedPosts.add(postId);
      await prefs.setStringList(_savedPostsKey, savedPosts);
    }
  }

  static Future<void> removeSavedPostId(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosts = prefs.getStringList(_savedPostsKey) ?? [];
    
    savedPosts.remove(postId);
    await prefs.setStringList(_savedPostsKey, savedPosts);
  }

  static Future<List<String>> getSavedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedPostsKey) ?? [];
  }

  static Future<bool> isSavedPost(String postId) async {
    final savedPosts = await getSavedPostIds();
    return savedPosts.contains(postId);
  }

  static Future<void> saveLikedPostId(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedPosts = prefs.getStringList(_likedPostsKey) ?? [];
    
    if (!likedPosts.contains(postId)) {
      likedPosts.add(postId);
      await prefs.setStringList(_likedPostsKey, likedPosts);
    }
  }

  static Future<void> removeLikedPostId(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedPosts = prefs.getStringList(_likedPostsKey) ?? [];
    
    likedPosts.remove(postId);
    await prefs.setStringList(_likedPostsKey, likedPosts);
  }

  static Future<List<String>> getLikedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_likedPostsKey) ?? [];
  }

  static Future<bool> isLikedPost(String postId) async {
    final likedPosts = await getLikedPostIds();
    return likedPosts.contains(postId);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedPostsKey);
    await prefs.remove(_likedPostsKey);
  }
}

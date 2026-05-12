import 'package:flutter/material.dart';
import '../services/feed_service.dart';

class FeedProvider extends ChangeNotifier {
  final FeedApi _feedApi = FeedApi();

  List<dynamic> feedPosts = [];
  String? feedNextCursor;
  bool feedLoading = false;
  bool feedLoadingMore = false;
  String? error;

  Future<void> loadFeed({String? cursor}) async {
    if (cursor != null && feedLoadingMore) return; // Prevent duplicate infinite scroll requests
    if (cursor == null && feedLoading) return; // Prevent duplicate initial loads

    try {
      if (cursor == null) {
        feedLoading = true;
        notifyListeners();
      } else {
        feedLoadingMore = true;
        // Don't notify here to avoid rebuilding the whole list during scroll
      }

      final result = await _feedApi.getFeed(cursor: cursor);

      if (cursor == null) {
        feedPosts = result['posts'] as List<dynamic>;
      } else {
        feedPosts.addAll(result['posts'] as List<dynamic>);
      }

      feedNextCursor = result['nextCursor'] as String?;
    } catch (e) {
      error = e.toString();
    } finally {
      feedLoading = false;
      feedLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshFeed() => loadFeed();

  Future<void> createPost(String text, {String? habitId}) async {
    try {
      await _feedApi.createPost(text, habitId: habitId);
      await refreshFeed();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _feedApi.likePost(postId);
      await refreshFeed();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _feedApi.unlikePost(postId);
      await refreshFeed();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

}
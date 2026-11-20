import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post_model.dart';

class FavoritesService {
  Box<Post> get _box => Hive.box<Post>('favoritesBox');

  Future<void> toggleFavorite(Post post) async {
    if (isFavorite(post.id)) {
      await _box.delete(post.id);
    } else {
      await _box.put(post.id, Post(id: post.id, title: post.title, body: post.body, userId: post.userId));
    }
  }

  bool isFavorite(int id) => _box.containsKey(id);
  List<Post> getFavorites() => _box.values.toList();
  ValueListenable<Box<Post>> listenable() => _box.listenable();
}

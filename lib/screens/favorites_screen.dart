import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/post_model.dart';
import '../services/favorites_service.dart';
import '../widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final service = FavoritesService();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ValueListenableBuilder<Box<Post>>(
        valueListenable: service.listenable(),
        builder: (context, box, _) {
          final posts = service.getFavorites();
          if (posts.isEmpty) {
            return const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.star_border, size: 64),
              SizedBox(height: 16),
              Text('No favorites yet'),
              SizedBox(height: 8),
              Text('Tap the star on any post to save it here.'),
            ]));
          }
          return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) => PostCard(
                  post: posts[i],
                  isFavorite: true,
                  onToggle: () => service.toggleFavorite(posts[i])));
        },
      ),
    );
  }
}

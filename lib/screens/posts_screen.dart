import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/post_model.dart';
import '../services/favorites_service.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _postsService = PostService();
  final _favorites = FavoritesService();
  late Future<List<Post>> _posts;
  @override
  void initState() { super.initState(); _posts = _postsService.getPosts(); }
  Future<void> _refresh() async {
    final next = _postsService.getPosts();
    setState(() => _posts = next);
    try { await next; } catch (_) { /* FutureBuilder displays the error. */ }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Posts'), actions: [
      ValueListenableBuilder<Box<Post>>(
        valueListenable: _favorites.listenable(),
        builder: (context, box, _) => IconButton(
          tooltip: 'Favorites',
          icon: Badge(label: Text('${box.length}'), child: const Icon(Icons.star)),
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const FavoritesScreen())),
        ),
      ),
    ]),
    body: FutureBuilder<List<Post>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return RefreshIndicator(onRefresh: _refresh, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * .3), Center(child: Text('${snapshot.error}', textAlign: TextAlign.center)),
        ]));
        final posts = snapshot.data ?? [];
        return ValueListenableBuilder<Box<Post>>(
          valueListenable: _favorites.listenable(),
          builder: (context, box, _) => RefreshIndicator(onRefresh: _refresh,
            child: ListView.builder(physics: const AlwaysScrollableScrollPhysics(), itemCount: posts.length,
              itemBuilder: (context, i) => PostCard(post: posts[i], isFavorite: _favorites.isFavorite(posts[i].id), onToggle: () => _favorites.toggleFavorite(posts[i]))),
          ),
        );
      },
    ),
  );
}

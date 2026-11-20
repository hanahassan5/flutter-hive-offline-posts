import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isFavorite;
  final VoidCallback onToggle;
  const PostCard({super.key, required this.post, required this.isFavorite, required this.onToggle});
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(child: Text('${post.id}')),
          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber : null),
            onPressed: onToggle,
          ),
        ),
      );
}

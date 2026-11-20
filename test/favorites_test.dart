import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_hive_offline_posts/models/post_model.dart';
import 'package:flutter_hive_offline_posts/screens/favorites_screen.dart';
import 'package:flutter_hive_offline_posts/services/favorites_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('posts_hive_test');
    Hive.init(dir.path);
    Hive.registerAdapter(PostAdapter());
  });
  setUp(() async {
    await Hive.openBox<Post>('postsBox');
    await Hive.openBox<Post>('favoritesBox');
  });
  tearDown(() async {
    await Hive.close();
  });
  tearDownAll(() async {
    await dir.delete(recursive: true);
  });

  test('toggle saves a copy and removes it by id', () async {
    final post = Post(id: 1, title: 'Title', body: 'Body', userId: 2);
    await Hive.box<Post>('postsBox').add(post);
    final service = FavoritesService();
    expect(service.isFavorite(1), isFalse);
    await service.toggleFavorite(post);
    expect(service.isFavorite(1), isTrue);
    expect(service.getFavorites(), hasLength(1));
    final copy = service.getFavorites().single;
    expect(identical(copy, post), isFalse);
    expect(
        [copy.id, copy.title, copy.body, copy.userId], [1, 'Title', 'Body', 2]);
    await Hive.box<Post>('postsBox').clear();
    expect(service.isFavorite(1), isTrue);
    await service.toggleFavorite(post);
    expect(service.isFavorite(1), isFalse);
    expect(service.getFavorites(), isEmpty);
  });

  testWidgets('empty favorites state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
    expect(find.text('No favorites yet'), findsOneWidget);
    expect(
        find.text('Tap the star on any post to save it here.'), findsOneWidget);
  });
}

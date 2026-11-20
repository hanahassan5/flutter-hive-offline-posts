import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_hive_offline_posts/models/post_model.dart';
import 'package:flutter_hive_offline_posts/screens/favorites_screen.dart';
import 'package:flutter_hive_offline_posts/widgets/post_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('posts_screenshots');
    Hive.init(dir.path);
    Hive.registerAdapter(PostAdapter());
    await Hive.openBox<Post>('favoritesBox');
  });
  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });
  testWidgets('Capture mocked states', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    final posts = List.generate(
        8,
        (i) => Post(
            id: i + 1,
            title: 'Sample post title ${i + 1}',
            body: 'This sample post is shown for a screenshot preview.',
            userId: 1));
    Widget app(Widget child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: child);
    Widget list({bool stars = false}) => Scaffold(
        appBar: AppBar(title: const Text('Posts'), actions: [
          Badge(label: Text(stars ? '3' : '0'), child: const Icon(Icons.star)),
          const SizedBox(width: 20)
        ]),
        body: ListView(children: [
          for (final post in posts)
            PostCard(
                post: post, isFavorite: stars && post.id <= 3, onToggle: () {})
        ]));
    Future<void> capture(String name, Widget widget) async {
      await tester.pumpWidget(app(widget));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../screenshots/$name.png'));
    }

    await capture('1_posts_online', list());
    await capture(
        '2_console_api',
        const Scaffold(
            body: Center(
                child: Text(
                    'MOCK CONSOLE\nLoaded from API and cached to Hive: 100'))));
    await capture('3_stars', list(stars: true));
    await capture('5_empty', const FavoritesScreen());
    await tester.runAsync(() async {
      for (final p in posts.take(3)) {
        await Hive.box<Post>('favoritesBox').put(p.id, p);
      }
    });
    await capture('4_favorites_screen', const FavoritesScreen());
    await capture('6_offline_posts', list(stars: true));
    await capture('7_offline_favorites', const FavoritesScreen());
    await capture(
        '8_no_cache_error',
        const Scaffold(
            body: Center(
                child: Text('Exception: No Internet and No Cached Data'))));
    await tester.binding.setSurfaceSize(null);
  });
}

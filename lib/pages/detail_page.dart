import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String animeTitle;
  final String animeSlug;

  const DetailPage({
    super.key,
    required this.animeTitle,
    required this.animeSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animeTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEF4444),
                Color(0xFF3B82F6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Slug: $animeSlug',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text('Video Player Placeholder'),
          ],
        ),
      ),
    );
  }
}

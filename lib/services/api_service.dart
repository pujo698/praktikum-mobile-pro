class ApiService {
  static Future<List<dynamic>> getOngoingAnime() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'title': 'One Piece',
        'episode': 'Episode 1090',
        'slug': 'one-piece',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'Jujutsu Kaisen Season 2',
        'episode': 'Episode 23',
        'slug': 'jujutsu-kaisen-s2',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'Frieren: Beyond Journey\'s End',
        'episode': 'Episode 18',
        'slug': 'sousou-no-frieren',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'Solo Leveling',
        'episode': 'Episode 2',
        'slug': 'solo-leveling',
        'image': 'https://via.placeholder.com/150'
      },
    ];
  }
}

class GhibliFilm {
  final String id;
  final String title;
  final String description;
  final String director;
  final String releaseDate;
  final String image;
  final String? originalTitle;
  final String? runningTime;
  final String? rtScore;
  final String? producer;
  final String? url;

  GhibliFilm({
    required this.id,
    required this.title,
    required this.description,
    required this.director,
    required this.releaseDate,
    required this.image,
    this.originalTitle,
    this.runningTime,
    this.rtScore,
    this.producer,
    this.url,
  });

  factory GhibliFilm.fromJson(Map<String, dynamic> json) {
    return GhibliFilm(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      director: json['director'] ?? '',
      releaseDate: json['release_date'] ?? '',
      image: json['image'] ?? '',
      originalTitle: json['original_title'],
      runningTime: json['running_time'],
      rtScore: json['rt_score'],
      producer: json['producer'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'director': director,
      'release_date': releaseDate,
      'image': image,
      'original_title': originalTitle,
      'running_time': runningTime,
      'rt_score': rtScore,
      'producer': producer,
      'url': url,
    };
  }
}

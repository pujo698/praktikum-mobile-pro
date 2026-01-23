class GhibliFilm {
  final String id;
  final String title;
  final String description;
  final String director;
  final String releaseDate;
  final String image;

  GhibliFilm({
    required this.id,
    required this.title,
    required this.description,
    required this.director,
    required this.releaseDate,
    required this.image,
  });

  factory GhibliFilm.fromJson(Map<String, dynamic> json) {
    return GhibliFilm(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      director: json['director'],
      releaseDate: json['release_date'],
      image: json['image'],
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
    };
  }
}

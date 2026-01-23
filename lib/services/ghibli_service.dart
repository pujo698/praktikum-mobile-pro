import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ghibli_film.dart';

class GhibliService {
  final String url = 'https://ghibliapi.vercel.app/films';

  Future<List<GhibliFilm>> fetchFilms() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => GhibliFilm.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data film');
    }
  }
}

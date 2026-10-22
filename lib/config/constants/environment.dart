// lib/config/constants/environment.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get theMovieDbKey {
    final key = dotenv.env['THE_MOVIEDB_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('THE_MOVIEDB_KEY no está configurada en .env');
    }
    return key;
  }
}
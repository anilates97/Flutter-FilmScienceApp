import 'package:flutter/cupertino.dart';
import 'package:movie_app/api/tmdb_config.dart';
import 'package:movie_app/theme/app_theme.dart';

class MovieUtils {
  static const String API_KEY = TmdbConfig.apiKey;
  static const String BASE_URL =
      "https://api.themoviedb.org/3/movie/top_rated?api_key=";

  static const String PAGE = "&page=";

  static const String IMAGE_PATH = "https://image.tmdb.org/t/p/w500";

  static const String TOP_RATED = BASE_URL + API_KEY;

  static const String VIDEO_URL = "https://api.themoviedb.org/3/movie/";
  static const String VIDEO_PATH = "/videos?api_key=$API_KEY";

  static const String VIDEO_YOUTUBE = "https://www.youtube.com/watch?v=";

  static const String MOVIE_DETAIL = "https://api.themoviedb.org/3/movie/";
  static const String MOVIE_DETAIL_PATH = "?api_key=$API_KEY";

  static String? imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return IMAGE_PATH + path;
  }

  // COLORS

  static Color colorLight = AppColors.gold;
  static Color colorDark = AppColors.black;

  static Color colorThird = AppColors.surfaceHigh;

  static Color colorFourth = AppColors.green;
}

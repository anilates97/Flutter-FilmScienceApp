import 'package:flutter/cupertino.dart';

class MovieUtils {
  static String API_KEY = "2af521b95bc66d438a7085aa9e8a02db";
  static String BASE_URL =
      "https://api.themoviedb.org/3/movie/top_rated?api_key=";

  static String PAGE = "&page=";

  static String IMAGE_PATH = "https://image.tmdb.org/t/p/w500";

  static String TOP_RATED = BASE_URL + API_KEY;

  static String VIDEO_URL = "https://api.themoviedb.org/3/movie/";
  static String VIDEO_PATH = "/videos?api_key=$API_KEY";

  static String VIDEO_YOUTUBE = "https://www.youtube.com/watch?v=";

  static String MOVIE_DETAIL = "https://api.themoviedb.org/3/movie/";
  static String MOVIE_DETAIL_PATH = "?api_key=$API_KEY";

  // COLORS

  static Color colorLight = const Color(0xFF8FE3CF);
  static Color colorDark = const Color(0xFF002B5B);

  static Color colorThird = const Color(0xFF256D85);

  static Color colorFourth = const Color(0xFF2B4865);
}


//https://api.themoviedb.org/3/movie/19404?api_key=2af521b95bc66d438a7085aa9e8a02db
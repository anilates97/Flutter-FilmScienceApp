import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:movie_app/model/fragment.dart';
import 'package:movie_app/model/movie_app.dart';
import 'package:movie_app/model/movie_app_detail.dart';

import '../api/tmdb_config.dart';
import '../api/utils.dart';

abstract class MovieService {
  Future<List<MovieModel>> fetchMovies();
  Future<List<ResultFragment>> movieFragment(String movieID);
  Future<MovieDetail> movieDetails(String movieID);
}

class APIMovieServices implements MovieService {
  List<MovieModel> topRatedList = [];

  Dio _createDio() {
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true,
    );
    return dio;
  }

  @override
  Future<List<MovieModel>> fetchMovies() async {
    try {
      TmdbConfig.validate();
      var url = MovieUtils.TOP_RATED;
      final dio = _createDio();

      final response = await dio.get(url);
      List<MovieModel> movieList = [];

      for (var item in response.data["results"]) {
        movieList.add(MovieModel.fromJson(item));
      }
      topRatedList.addAll(movieList);

      return movieList;
    } catch (e) {
      throw Exception("API Hatası: $e");
    }
  }

  @override
  Future<List<ResultFragment>> movieFragment(String movieID) async {
    List<ResultFragment> allFragment = [];
    try {
      TmdbConfig.validate();
      var url = MovieUtils.VIDEO_URL + movieID + MovieUtils.VIDEO_PATH;
      final dio = _createDio();

      final response = await dio.get(url);
      List<ResultFragment> movieList = [];

      for (var item in response.data['results']) {
        movieList.add(ResultFragment.fromJson(item));
      }

      allFragment.addAll(movieList);

      return allFragment;
    } catch (e) {
      throw Exception("API Hatası: $e");
    }
  }

  @override
  Future<MovieDetail> movieDetails(String movieID) async {
    try {
      TmdbConfig.validate();
      var url =
          MovieUtils.MOVIE_DETAIL + movieID + MovieUtils.MOVIE_DETAIL_PATH;
      final dio = _createDio();

      final response = await dio.get(url);
      final data = response.data as Map<String, dynamic>;
      final cevap = MovieDetail.fromJson(data);

      return cevap;
    } catch (e) {
      throw Exception("API Hatası: $e");
    }
  }
}

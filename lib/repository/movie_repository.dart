import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:movie_app/model/movie_app.dart';

import '../api/tmdb_config.dart';
import '../api/utils.dart';

abstract class MovieRepository {
  Future<List<Result>> fetchMovies();
  Future<List<Result>> nextMovies(int sayac);
  Future<List<Result>> previousMovies(int sayac);
}

class APIMovieRepository implements MovieRepository {
  List<MovieModel> movies = [];
  static int sayac = 1;

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
  Future<List<Result>> fetchMovies() async {
    try {
      TmdbConfig.validate();
      final url = MovieUtils.TOP_RATED + MovieUtils.PAGE + sayac.toString();
      final dio = _createDio();

      final response = await dio.get(url);

      MovieModel movieModel = MovieModel.fromJson(response.data);
      return movieModel.results ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['status_message'] ?? e.message;
      throw Exception("Repository HATA: $message");
    }
  }

  @override
  Future<List<Result>> nextMovies(int sayac) async {
    try {
      TmdbConfig.validate();
      final url = MovieUtils.TOP_RATED + MovieUtils.PAGE + sayac.toString();
      final dio = _createDio();

      final response = await dio.get(url);

      MovieModel movieModel = MovieModel.fromJson(response.data);
      return movieModel.results ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['status_message'] ?? e.message;
      throw Exception("Repository HATA: $message");
    }
  }

  @override
  Future<List<Result>> previousMovies(int sayac) async {
    try {
      TmdbConfig.validate();
      final url = MovieUtils.TOP_RATED + MovieUtils.PAGE + sayac.toString();
      final dio = _createDio();

      final response = await dio.get(url);

      MovieModel movieModel = MovieModel.fromJson(response.data);
      return movieModel.results ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['status_message'] ?? e.message;
      throw Exception("Repository HATA: $message");
    }
  }
}

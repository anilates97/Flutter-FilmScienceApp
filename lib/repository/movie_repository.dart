import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/model/movie_app.dart';

import '../api/utils.dart';

abstract class MovieRepository {
  Future<List<Result>> fetchMovies();
  Future<List<Result>> nextMovies(sayac);
  Future<List<Result>> previousMovies(sayac);
}

class APIMovieRepository implements MovieRepository {
  List<MovieModel> movies = [];
  static int sayac = 1;

  @override
  Future<List<Result>> fetchMovies() async {
    try {
      var url = MovieUtils.TOP_RATED + MovieUtils.PAGE;
      print("Repo Metot Çalıştı URL: $url");
      Dio dio = Dio();

      //Eski telefonlar için
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get(url);
      debugPrint("REPO RESPONSE: ${response.data['results']}");

      MovieModel movieModel = MovieModel.fromJson(response.data);
      return movieModel.results!;
    } on DioError catch (e) {
      print(e.toString());
      throw Exception("Repository HATA:");
    }
  }

  @override
  Future<List<Result>> nextMovies(sayac) async {
    String url = "";
    try {
      url = MovieUtils.TOP_RATED + MovieUtils.PAGE + sayac.toString();

      print("nextMovies Metot Çalıştı URL: $url");
      Dio dio = Dio();

      //Eski telefonlar için
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get(url);
      debugPrint("REPO RESPONSE: ${response.data['results']}");

      MovieModel movieModel = MovieModel.fromJson(response.data);
      return movieModel.results!;
    } on DioError catch (e) {
      print(e.toString());
      throw Exception("Repository HATA:");
    }
  }

  @override
  Future<List<Result>> previousMovies(sayac) async {
    String url = "";
    try {
      url = MovieUtils.TOP_RATED + MovieUtils.PAGE + sayac.toString();

      print("nextMovies Metot Çalıştı URL: $url");
      Dio dio = Dio();

      //Eski telefonlar için
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get(url);
      debugPrint("REPO RESPONSE: ${response.data['results']}");

      MovieModel movieModel = MovieModel.fromJson(response.data);
      return movieModel.results!;
    } on DioError catch (e) {
      print(e.toString());
      throw Exception("Repository HATA:");
    }
  }
}

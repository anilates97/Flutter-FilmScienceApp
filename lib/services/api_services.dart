import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/model/fragment.dart';
import 'package:movie_app/model/movie_app.dart';
import 'package:movie_app/model/movie_app_detail.dart';

import '../api/utils.dart';

abstract class MovieService {
  Future<List<MovieModel>> fetchMovies();
  Future<List<ResultFragment>> movieFragment(String movieID);
  Future<MovieDetail> movieDetails(String movieID);
}

class APIMovieServices implements MovieService {
  List<MovieModel> topRatedList = [];
  @override
  Future<List<MovieModel>> fetchMovies() async {
    try {
      var url = MovieUtils.TOP_RATED;
      print("METOT ÇALIŞTI");
      Dio dio = Dio();
      print("URL: " + url);
      //Eski telefonlar için
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get(url);
      final data = response.data['results'];
      debugPrint("dönen cevap: ${response.data['results']}");
      List<MovieModel> movieList = [];

      for (var item in response.data["results"]) {
        movieList.add(MovieModel.fromJson(item));
      }
      topRatedList.addAll(movieList);

      return movieList;
    } catch (e) {
      print(e.toString());
      throw Exception("API Hatası");
    }
  }

  @override
  Future<List<ResultFragment>> movieFragment(String movieID) async {
    List<ResultFragment> allFragment = [];
    try {
      var url = MovieUtils.VIDEO_URL + movieID + MovieUtils.VIDEO_PATH;

      //Eski telefonlar için
      Dio dio = Dio();
      print("URL: " + url);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get(url);
      final data = response.data['results'];
      debugPrint("dönen cevap: ${response.data['results']}");
      List<ResultFragment> movieList = [];

      for (var item in response.data['results']) {
        movieList.add(ResultFragment.fromJson(item));
      }

      allFragment.addAll(movieList);

      return allFragment;
    } catch (e) {
      print(e.toString());
      throw Exception("API Hatası");
    }
  }

  @override
  Future<MovieDetail> movieDetails(String movieID) async {
    try {
      var url =
          MovieUtils.MOVIE_DETAIL + movieID + MovieUtils.MOVIE_DETAIL_PATH;
      //Eski telefonlar için
      Dio dio = Dio();
      print("URL: " + url);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.get(url);
      final data = response.data as Map<String, dynamic>;
      final cevap = MovieDetail.fromJson(data);
      debugPrint("dönen cevap: $cevap");

      return cevap;
    } catch (e) {
      print(e.toString());
      throw Exception("API Hatası");
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/application/movie_notifier.dart';
import 'package:movie_app/repository/movie_repository.dart';

final movieRepositoryProvider =
    Provider<MovieRepository>((ref) => APIMovieRepository());

final movieNotifierProvider = StateNotifierProvider<MovieNotifier, MovieState>(
    (ref) => MovieNotifier(ref.watch(movieRepositoryProvider)));

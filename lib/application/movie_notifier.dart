import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/model/movie_app.dart';
import 'package:movie_app/repository/movie_repository.dart';

abstract class MovieState {
  const MovieState();
}

class MovieInitial extends MovieState {
  final List<MovieModel> movies;
  const MovieInitial(this.movies);
}

class MovieLoading extends MovieState {
  const MovieLoading();
}

class MovieLoaded extends MovieState {
  final List<Result> movies;
  const MovieLoaded(this.movies);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MovieLoaded && o.movies == movies;
  }

  @override
  int get hashCode => movies.hashCode;
}

class MovieError extends MovieState {
  final String message;
  const MovieError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MovieError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class MovieNotifier extends StateNotifier<MovieState> {
  final MovieRepository _movieRepository;

  MovieNotifier(this._movieRepository) : super(const MovieInitial([]));

  Future<void> getMovies() async {
    try {
      state = const MovieLoading();
      final movies = await _movieRepository.fetchMovies();
      state = MovieLoaded(movies);
    } catch (e) {
      state = const MovieError("Filmleri yüklerken hata meydana geldi");
    }
  }

  Future<void> nextMovies(int sayac) async {
    try {
      state = const MovieLoading();
      final movies = await _movieRepository.nextMovies(sayac);

      state = MovieLoaded(movies);
    } catch (e) {
      state =
          const MovieError("Sıradaki filmleri yüklerken hata meydana geldi");
    }
  }

  Future<void> previousMovies(int sayac) async {
    try {
      state = const MovieLoading();
      final movies = await _movieRepository.nextMovies(sayac);

      state = MovieLoaded(movies);
    } catch (e) {
      state =
          const MovieError("Sıradaki filmleri yüklerken hata meydana geldi");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/application/movie_notifier.dart';
import 'package:movie_app/model/movie_app.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/pages/signin_page.dart';
import 'package:movie_app/repository/api_provider.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

import '../repository/movie_repository.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  String _query = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (() {
      return ref.read(movieNotifierProvider.notifier).getMovies();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return CinematicScaffold(
      appBar: AppBar(
        title: const Text("Film Science"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                if (_authService.getCurrentUser() != null) {
                  _authService.signOut();
                  setState(() {});
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                  ).then((_) => setState(() {}));
                }
              },
              icon: Icon(
                _authService.getCurrentUser() != null
                    ? Icons.logout
                    : Icons.person_outline,
                size: 18,
              ),
              label: Text(
                _authService.getCurrentUser() != null ? "Logout" : "Login",
              ),
            ),
          ),
        ],
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(movieNotifierProvider);

          if (state is MovieInitial || state is MovieLoading) {
            return const LoadingPosterGrid();
          } else if (state is MovieLoaded) {
            if (state.movies.isEmpty) {
              return StateMessage(
                icon: Icons.movie_filter_outlined,
                title: "No movies found",
                message: "TMDB returned an empty list.",
                onRetry: () =>
                    ref.read(movieNotifierProvider.notifier).getMovies(),
              );
            }
            return _buildDiscovery(context, state.movies, ref);
          } else if (state is MovieError) {
            return StateMessage(
              icon: Icons.wifi_off_rounded,
              title: "Movies could not load",
              message: state.message,
              onRetry: () =>
                  ref.read(movieNotifierProvider.notifier).getMovies(),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildDiscovery(
      BuildContext context, List<Result> movies, WidgetRef ref) {
    final filteredMovies = _query.trim().isEmpty
        ? movies
        : movies
            .where((movie) => (movie.title ?? "")
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();
    final featured = movies.first;

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () => ref.read(movieNotifierProvider.notifier).getMovies(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _FeaturedMovie(movie: featured)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.muted),
                  hintText: "Search top-rated films",
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text("Top Rated", style: AppText.title),
                  const Spacer(),
                  MetaChip(label: "Curated page ${APIMovieRepository.sayac}"),
                ],
              ),
            ),
          ),
          if (filteredMovies.isEmpty)
            const SliverFillRemaining(
              child: StateMessage(
                icon: Icons.search_off,
                title: "No matching movies",
                message: "Try a different title.",
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _MoviePosterCard(
                    movie: filteredMovies[index],
                    onTap: () => _openMovie(filteredMovies[index]),
                  ),
                  childCount: filteredMovies.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 30),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: APIMovieRepository.sayac == 1
                          ? null
                          : () {
                              APIMovieRepository.sayac--;
                              ref
                                  .read(movieNotifierProvider.notifier)
                                  .previousMovies(APIMovieRepository.sayac);
                            },
                      icon: const Icon(Icons.chevron_left),
                      label: const Text("Previous"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 52),
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        APIMovieRepository.sayac++;
                        ref
                            .read(movieNotifierProvider.notifier)
                            .nextMovies(APIMovieRepository.sayac);
                      },
                      icon: const Icon(Icons.chevron_right),
                      label: const Text("Next page"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMovie(Result movie) {
    final movieId = movie.id;
    if (movieId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailPage(movieID: movieId.toString()),
      ),
    );
  }
}

class _FeaturedMovie extends StatelessWidget {
  final Result movie;

  const _FeaturedMovie({required this.movie});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        MovieUtils.imageUrl(movie.backdropPath ?? movie.posterPath);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (movie.id == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailPage(movieID: movie.id.toString()),
            ),
          );
        },
        child: Container(
          height: 245,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MovieImage(imageUrl: imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0xAA0B1020),
                      Color(0xEE0B1020),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MetaChip(label: "Featured Pick"),
                    const Spacer(),
                    Text(
                      movie.title ?? "Untitled",
                      style: AppText.hero,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (movie.releaseDate != null)
                          MetaChip(
                            label: movie.releaseDate!.year.toString(),
                            icon: Icons.calendar_today_outlined,
                          ),
                        MetaChip(
                          label: (movie.voteAverage ?? 0).toStringAsFixed(1),
                          icon: Icons.star_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoviePosterCard extends StatelessWidget {
  final Result movie;
  final VoidCallback onTap;

  const _MoviePosterCard({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = MovieUtils.imageUrl(movie.posterPath);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MovieImage(imageUrl: imageUrl),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.gold),
                          const SizedBox(width: 3),
                          Text(
                            (movie.voteAverage ?? 0).toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? "Untitled",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    movie.releaseDate?.year.toString() ?? "Unknown year",
                    style: AppText.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

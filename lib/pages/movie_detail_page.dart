import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/fav_page.dart';
import 'package:movie_app/pages/replies_page.dart';
import 'package:movie_app/pages/signin_page.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/services/database_service.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

import '../widget/build_fragment_widget.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieID;
  MovieDetailPage({Key? key, required this.movieID}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final APIMovieServices _services = APIMovieServices();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  bool _favoriteBusy = false;

  @override
  Widget build(BuildContext context) {
    return CinematicScaffold(
      child: FutureBuilder<MovieDetail>(
        future: _services.movieDetails(widget.movieID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StateMessage(
              icon: Icons.error_outline,
              title: "Movie could not load",
              message: snapshot.error.toString(),
            );
          }
          if (!snapshot.hasData) {
            return const LoadingPosterGrid();
          }

          final movie = snapshot.data!;
          final posterUrl = MovieUtils.imageUrl(movie.posterPath);
          final backdropUrl = MovieUtils.imageUrl(movie.backdropPath);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(
                  movie: movie,
                  backdropUrl: backdropUrl,
                  posterUrl: posterUrl,
                  favoriteIcon: _FavoriteIcon(
                    userId: _authService.getCurrentUser(),
                    movieId: movie.id?.toString(),
                    databaseService: _databaseService,
                  ),
                  onBack: () => Navigator.pop(context),
                  onFavorite: () => _toggleFavorite(movie, posterUrl ?? ""),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          MetaChip(
                            label: _country(movie),
                            icon: Icons.public,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text("Overview", style: AppText.title),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview ?? "No overview available.",
                        style: AppText.body.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 18),
                      Text("Genres", style: AppText.title),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genres(movie)
                            .map((genre) => MetaChip(label: genre))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RepliesPage(widget.movieID),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.format_quote_rounded),
                              label: const Text("Replikler"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FavPage(movie),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.favorite),
                              label: const Text("Favoriler"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.text,
                                minimumSize: const Size(48, 48),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text("Fragman", style: AppText.title),
                          const SizedBox(width: 8),
                          const Icon(Icons.play_circle_fill,
                              color: AppColors.gold, size: 22),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BuildFragmentWidget(widget.movieID, movie.backdropPath),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(MovieDetail movie, String posterUrl) async {
    final userId = _authService.getCurrentUser();
    if (userId == null) {
      _showSignInDialog();
      return;
    }
    if (movie.id == null || _favoriteBusy) return;

    setState(() => _favoriteBusy = true);
    try {
      final isFavorite =
          await _databaseService.isDuplicateUniqueName(movie.id!, userId);
      if (!mounted) return;

      if (isFavorite) {
        await _databaseService.deleteMovieFromFirebase(
          userId,
          movie.id.toString(),
        );
        _showFavoriteSnackBar(
          "Basarili",
          "Film favorilerden kaldirildi!",
          ContentType.warning,
        );
      } else {
        await _databaseService.addMovieToDatabase(
          userId,
          movie,
          posterUrl,
          movie.id.toString(),
        );
        _showFavoriteSnackBar(
          "Basarili",
          "Film favorilere eklendi!",
          ContentType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Favori islemi basarisiz: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }

  void _showSignInDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Sign in required"),
        content: const Text("Please sign in before adding favorites."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            },
            child: const Text("Sign in"),
          ),
        ],
      ),
    );
  }

  void _showFavoriteSnackBar(
    String title,
    String message,
    ContentType contentType,
  ) {
    final snackBar = SnackBar(
      duration: const Duration(milliseconds: 1000),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        color: AppColors.surfaceHigh,
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<String> _genres(MovieDetail movie) {
    final genres = movie.genres
            ?.map((genre) => genre.name)
            .whereType<String>()
            .where((name) => name.trim().isNotEmpty)
            .toList() ??
        [];
    return genres.isEmpty ? ["Unknown"] : genres;
  }

  String _country(MovieDetail movie) {
    final countries = movie.productionCountries;
    if (countries == null || countries.isEmpty) return "Unknown";
    return countries.first.name ?? "Unknown";
  }
}

class _HeroHeader extends StatelessWidget {
  final MovieDetail movie;
  final String? backdropUrl;
  final String? posterUrl;
  final Widget favoriteIcon;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const _HeroHeader({
    required this.movie,
    required this.backdropUrl,
    required this.posterUrl,
    required this.favoriteIcon,
    required this.onBack,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MovieImage(imageUrl: backdropUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000),
                  Color(0xAA0B1020),
                  AppColors.black,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back,
                    onPressed: onBack,
                  ),
                  const Spacer(),
                  Material(
                    color: AppColors.black.withValues(alpha: 0.48),
                    shape: const CircleBorder(
                      side: BorderSide(color: Color(0x44FFFFFF)),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onFavorite,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(child: favoriteIcon),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 116,
                  height: 174,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: MovieImage(imageUrl: posterUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MetaChip(label: "TMDB detail"),
                        const SizedBox(height: 10),
                        Text(
                          movie.title ?? "Untitled",
                          style: AppText.hero,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.tagline?.isNotEmpty == true
                              ? movie.tagline!
                              : "A cinematic discovery from TMDB.",
                          style: AppText.muted,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteIcon extends StatelessWidget {
  final String? userId;
  final String? movieId;
  final FirebaseDatabaseService databaseService;

  const _FavoriteIcon({
    required this.userId,
    required this.movieId,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null || movieId == null) {
      return const Icon(Icons.favorite_outline, size: 25);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: databaseService.fetchMovieFromFirebase(userId!, movieId!),
      builder: (context, snapshot) {
        if (snapshot.data?.exists == true) {
          return const Icon(Icons.favorite, color: AppColors.gold, size: 25);
        }
        return const Icon(Icons.favorite_outline, size: 25);
      },
    );
  }
}

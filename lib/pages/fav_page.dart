import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/pages/replies_page.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/services/database_service.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

class FavPage extends StatefulWidget {
  final MovieDetail? movieDetail;
  FavPage(this.movieDetail, {Key? key}) : super(key: key);

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUser();

    return CinematicScaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      child: userId == null
          ? const StateMessage(
              icon: Icons.lock_outline,
              title: "Sign in required",
              message: "Login to build your personal movie collection.",
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _databaseService.fetchMoviesFromFirebase(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return StateMessage(
                    icon: Icons.error_outline,
                    title: "Favorites could not load",
                    message: snapshot.error.toString(),
                  );
                }
                if (!snapshot.hasData) {
                  return const LoadingPosterGrid();
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = _query.trim().isEmpty
                    ? docs
                    : docs
                        .where((doc) => (doc.data()["movieName"] ?? "")
                            .toString()
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                        .toList();

                if (docs.isEmpty) {
                  return const StateMessage(
                    icon: Icons.favorite_border,
                    title: "No favorites yet",
                    message:
                        "Add movies from the detail page to start a collection.",
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your collection", style: AppText.hero),
                            const SizedBox(height: 8),
                            Text(
                              "${docs.length} saved films curated for later.",
                              style: AppText.muted,
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              style: const TextStyle(color: AppColors.text),
                              decoration: const InputDecoration(
                                prefixIcon:
                                    Icon(Icons.search, color: AppColors.muted),
                                hintText: "Search favorites",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (filteredDocs.isEmpty)
                      const SliverFillRemaining(
                        child: StateMessage(
                          icon: Icons.search_off,
                          title: "No matching favorites",
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverList.separated(
                          itemCount: filteredDocs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final data = filteredDocs[index].data();
                            final movieId = data["id"]?.toString() ?? "";
                            final movieName =
                                data["movieName"]?.toString() ?? "Untitled";
                            final imageUrl = data["url"]?.toString() ?? "";
                            final subject =
                                data["movieSubject"]?.toString() ?? "";
                            final year = _releaseYear(data["releaseDate"]);

                            return _FavoriteMovieCard(
                              movieName: movieName,
                              imageUrl: imageUrl,
                              subtitle: subject,
                              year: year,
                              onOpen: movieId.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              MovieDetailPage(movieID: movieId),
                                        ),
                                      );
                                    },
                              onReply: () =>
                                  _showReplySheet(movieName, movieId),
                              onReplies: movieId.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RepliesPage(movieId),
                                        ),
                                      );
                                    },
                              onRemove: movieId.isEmpty
                                  ? null
                                  : () async {
                                      await _databaseService
                                          .deleteMovieFromFirebase(
                                        userId,
                                        movieId,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("Removed from favorites"),
                                          ),
                                        );
                                      }
                                    },
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Future<void> _showReplySheet(String movieName, String movieId) async {
    if (movieId.isEmpty) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _ReplySheet(
        movieName: movieName,
        movieId: movieId,
        databaseService: _databaseService,
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quote saved")),
      );
    }
  }

  String _releaseYear(dynamic value) {
    if (value is Timestamp) return value.toDate().year.toString();
    if (value is DateTime) return value.year.toString();
    return "Saved";
  }
}

class _ReplySheet extends StatefulWidget {
  final String movieName;
  final String movieId;
  final FirebaseDatabaseService databaseService;

  const _ReplySheet({
    required this.movieName,
    required this.movieId,
    required this.databaseService,
  });

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, result) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Add quote", style: AppText.title),
            const SizedBox(height: 6),
            Text(widget.movieName, style: AppText.muted),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 4,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                hintText: "Write a memorable line or comment",
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: Icon(_isSaving
                    ? Icons.hourglass_top_rounded
                    : Icons.format_quote_rounded),
                label: Text(_isSaving ? "Saving quote..." : "Save quote"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final reply = _controller.text.trim();
    if (reply.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    setState(() => _isSaving = true);
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await widget.databaseService.writeRepliesOnMovie(
        widget.movieName,
        reply,
        widget.movieId,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quote could not be saved: $e")),
      );
    }
  }
}

class _FavoriteMovieCard extends StatelessWidget {
  final String movieName;
  final String imageUrl;
  final String subtitle;
  final String year;
  final VoidCallback? onOpen;
  final VoidCallback? onReply;
  final VoidCallback? onReplies;
  final VoidCallback? onRemove;

  const _FavoriteMovieCard({
    required this.movieName,
    required this.imageUrl,
    required this.subtitle,
    required this.year,
    required this.onOpen,
    required this.onReply,
    required this.onReplies,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MovieImage(
                  imageUrl: imageUrl,
                  width: 92,
                  height: 132,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movieName,
                            style: AppText.title.copyWith(fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: AppColors.surfaceHigh,
                          iconColor: AppColors.text,
                          onSelected: (value) {
                            Future<void>.delayed(
                              const Duration(milliseconds: 140),
                              () {
                                if (!context.mounted) return;
                                if (value == "reply") onReply?.call();
                                if (value == "replies") onReplies?.call();
                                if (value == "remove") onRemove?.call();
                              },
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "reply",
                              child: Text("Add quote"),
                            ),
                            const PopupMenuItem(
                              value: "replies",
                              child: Text("View quotes"),
                            ),
                            PopupMenuItem(
                              value: "remove",
                              child: Text(
                                "Remove favorite",
                                style: TextStyle(color: AppColors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MetaChip(label: year, icon: Icons.bookmark_added_outlined),
                    const SizedBox(height: 10),
                    Text(
                      subtitle.isEmpty ? "No overview saved." : subtitle,
                      style: AppText.muted,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onReply,
                          icon:
                              const Icon(Icons.add_comment_outlined, size: 18),
                          label: const Text("Quote"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 42),
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: onReplies,
                          icon:
                              const Icon(Icons.format_quote_rounded, size: 18),
                          label: const Text("Read"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 42),
                            foregroundColor: AppColors.text,
                            side: const BorderSide(color: AppColors.border),
                          ),
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

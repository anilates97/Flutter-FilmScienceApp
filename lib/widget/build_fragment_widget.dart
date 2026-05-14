import 'package:flutter/material.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/fragment.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildFragmentWidget extends StatefulWidget {
  final String movieID;
  final String? backdropPath;
  BuildFragmentWidget(this.movieID, this.backdropPath, {Key? key})
      : super(key: key);

  @override
  State<BuildFragmentWidget> createState() => _BuildFragmentWidgetState();
}

class _BuildFragmentWidgetState extends State<BuildFragmentWidget> {
  final APIMovieServices _movieServices = APIMovieServices();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: FutureBuilder<List<ResultFragment>>(
        future: _movieServices.movieFragment(widget.movieID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StateMessage(
              icon: Icons.play_disabled_outlined,
              title: "Trailers could not load",
              message: snapshot.error.toString(),
            );
          }
          if (!snapshot.hasData) {
            return const FilmLoadingIndicator(label: "Loading trailers");
          }

          final fragments = snapshot.data ?? [];
          if (fragments.isEmpty) {
            return const StateMessage(
              icon: Icons.play_disabled_outlined,
              title: "Trailer unavailable",
              message: "This movie does not have a playable trailer yet.",
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fragments.length,
            itemBuilder: (context, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final key = fragments[index].key;
                  if (key == null || key.isEmpty) return;
                  Uri url = Uri.parse(MovieUtils.VIDEO_YOUTUBE + key);
                  _launchUrl(url);
                },
                child: Container(
                  width: 290,
                  margin: const EdgeInsets.only(right: 14),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MovieImage(
                        imageUrl: MovieUtils.imageUrl(widget.backdropPath),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x22000000),
                              Color(0xDD0B1020),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.black,
                            size: 42,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Text(
                          fragments[index].name ?? "Trailer",
                          style: AppText.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trailer could not be opened.")),
      );
    }
  }
}

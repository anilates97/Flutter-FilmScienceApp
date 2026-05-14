import 'package:flutter/material.dart';
import 'package:movie_app/services/database_service.dart';
import 'package:movie_app/theme/app_theme.dart';

class BuildReplyWidget extends StatefulWidget {
  final String movieID;
  final String reply;
  final int likes;
  final String movieName;
  final String? userId;

  BuildReplyWidget({
    Key? key,
    required this.reply,
    required this.likes,
    required this.movieID,
    this.movieName = "Movie",
    this.userId,
  }) : super(key: key);

  @override
  State<BuildReplyWidget> createState() => _BuildReplyWidgetState();
}

class _BuildReplyWidgetState extends State<BuildReplyWidget> {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  IconData icon = Icons.favorite_border;

  @override
  Widget build(BuildContext context) {
    final shortUser = widget.userId == null || widget.userId!.isEmpty
        ? "Community"
        : "User ${widget.userId!.substring(0, widget.userId!.length < 6 ? widget.userId!.length : 6)}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded,
              color: AppColors.gold, size: 30),
          const SizedBox(height: 10),
          Text(
            "${widget.movieName} · $shortUser",
            style: AppText.muted.copyWith(color: AppColors.green),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.reply,
            style: AppText.body.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Material(
                color: icon == Icons.favorite
                    ? AppColors.gold.withValues(alpha: 0.16)
                    : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    setState(() {
                      if (icon == Icons.favorite) {
                        icon = Icons.favorite_border;
                      } else {
                        icon = Icons.favorite;
                        _databaseService.likeReply(
                            widget.movieID, widget.reply);
                      }
                    });
                  },
                  child: SizedBox(
                    height: 46,
                    width: 46,
                    child: Icon(
                      icon,
                      color: icon == Icons.favorite
                          ? AppColors.gold
                          : AppColors.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "${widget.likes} likes",
                  style: AppText.muted.copyWith(color: AppColors.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

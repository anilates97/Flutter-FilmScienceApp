import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/services/database_service.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

import '../model/reply.dart';
import '../widget/build_reply_widget.dart';

class RepliesPage extends StatefulWidget {
  final String movieID;
  RepliesPage(this.movieID, {Key? key}) : super(key: key);

  @override
  State<RepliesPage> createState() => _RepliesPageState();
}

class _RepliesPageState extends State<RepliesPage> {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  @override
  Widget build(BuildContext context) {
    return CinematicScaffold(
      appBar: AppBar(
        title: const Text("Quotes"),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: _databaseService.readReplyOnMovie(widget.movieID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StateMessage(
              icon: Icons.error_outline,
              title: "Quotes could not load",
              message: snapshot.error.toString(),
            );
          }
          if (!snapshot.hasData) {
            return const LoadingPosterGrid();
          }
          if (!snapshot.data!.exists) {
            return const StateMessage(
              icon: Icons.format_quote_outlined,
              title: "No quotes yet",
              message: "Add the first memorable line from favorites.",
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final rep = data?['reply'] as List<dynamic>? ?? [];
          final movieName = data?['movieName']?.toString() ?? "Movie";
          final replies = rep
              .map((element) => Reply.fromJson(
                    Map<String, dynamic>.from(element as Map),
                  ))
              .where((reply) => reply.reply.trim().isNotEmpty)
              .toList();

          if (replies.isEmpty) {
            return StateMessage(
              icon: Icons.format_quote_outlined,
              title: "No quotes yet",
              message: "$movieName has no saved replies.",
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            itemBuilder: (context, index) {
              return BuildReplyWidget(
                likes: replies[index].vote,
                reply: replies[index].reply,
                movieID: snapshot.data!.get('id').toString(),
                movieName: movieName,
                userId: replies[index].userId,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemCount: replies.length,
          );
        },
      ),
    );
  }
}

class ChangeButton extends StatefulWidget {
  const ChangeButton({Key? key}) : super(key: key);

  @override
  State<ChangeButton> createState() => _ChangeButtonState();
}

class _ChangeButtonState extends State<ChangeButton> {
  IconData icon = Icons.favorite_border;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.gold),
      onPressed: () {
        setState(() {
          icon = Icons.favorite;
        });
      },
    );
  }
}

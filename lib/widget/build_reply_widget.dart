import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/services/database_service.dart';

class BuildReplyWidget extends StatefulWidget {
  String movieID;
  String reply;
  int likes;
  BuildReplyWidget(
      {Key? key,
      required this.reply,
      required this.likes,
      required this.movieID})
      : super(key: key);

  @override
  State<BuildReplyWidget> createState() => _BuildReplyWidgetState();
}

class _BuildReplyWidgetState extends State<BuildReplyWidget> {
  FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  IconData icon = Icons.favorite_border;
  @override
  Widget build(BuildContext context) {
    print("MOVIE IDD: ${widget.movieID}");
    return Card(
      color: MovieUtils.colorDark,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Container(
          width: 30,
          height: 50,
          child: IconButton(
              onPressed: () {
                setState(() {
                  if (icon == Icons.favorite) {
                    icon = Icons.favorite_border;
                  } else {
                    icon = Icons.favorite;
                    _databaseService.likeReply(widget.movieID);
                  }
                });
              },
              icon: Icon(
                icon,
                color: MovieUtils.colorFourth,
              )),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 150,
          child: Text(
            widget.reply,
            style: TextStyle(color: MovieUtils.colorLight),
          ),
        ),
        Column(
          children: [
            Text("likes", style: TextStyle(color: MovieUtils.colorThird)),
            Chip(
              label: Container(
                width: 20,
                height: 20,
                child: Center(
                  child: Text(
                    widget.likes.toString(),
                    style: TextStyle(color: MovieUtils.colorDark),
                  ),
                ),
              ),
            )
          ],
        )
      ]),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/services/database_service.dart';

import '../model/reply.dart';
import '../widget/build_reply_widget.dart';

class RepliesPage extends StatefulWidget {
  String movieID;
  RepliesPage(this.movieID, {Key? key}) : super(key: key);

  @override
  State<RepliesPage> createState() => _RepliesPageState();
}

class _RepliesPageState extends State<RepliesPage> {
  FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  IconData icon = Icons.favorite_border;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: _databaseService.readReplyOnMovie(widget.movieID),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              var rep = snapshot.data!.get('reply') as List<dynamic>;
              //Map<String, dynamic> replikler = rep;
              List<Reply> reps = [];

              rep.forEach(
                (element) {
                  Reply reply = Reply.fromJson(element);

                  reps.add(reply);
                },
              );

              print("REPS LENGTH: ${reps.length - 1}");

              var data = snapshot.data!.get('reply');

              List<dynamic> replies = [];
              replies.add(data);
              return Container(
                color: MovieUtils.colorLight,
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return BuildReplyWidget(
                        likes: reps[index].vote,
                        reply: reps[index].reply,
                        movieID: snapshot.data!.get('id').toString(),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        height: 2,
                        color: Colors.black,
                      );
                    },
                    itemCount: reps.length),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
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
    print("Change button build çalıştıo");
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        setState(() {
          icon = Icons.favorite;
        });
      },
    );
  }
}

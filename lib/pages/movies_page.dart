import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/reply.dart';
import 'package:movie_app/pages/replies_page.dart';
import 'package:movie_app/services/database_service.dart';

class MoviesPage extends StatefulWidget {
  String movieID;
  MoviesPage(this.movieID, {Key? key}) : super(key: key);

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: _databaseService.readRepliesOnMovie(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Container(
                color: MovieUtils.colorDark,
                child: ListView.builder(
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    print("SNAPSHOT SIZE :: ${snapshot.data!.size.toString()}");
                    final replies = snapshot.data!.docs;

                    var rep =
                        replies.elementAt(index).get('reply') as List<dynamic>;
                    //Map<String, dynamic> replikler = rep;
                    List<dynamic> reps = [];

                    Map<String, dynamic> map = {};

                    List<Reply> kk = [];
                    rep.forEach(
                      (element) {
                        Reply reply = Reply.fromJson(element);
                        print("element: ${reply.reply}");
                        kk.add(reply);
                      },
                    );

                    // var dataRep = Reply.fromJson(rep);

                    //print("DATAREPP: ${dataRep.reply}");
                    // for (String data in rep) {
                    //   print("DATA::: $data");
                    // }

                    // Reply reply = Reply.fromJson(
                    //     snapshot.data!.docs.elementAt(index).get('reply'));

                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RepliesPage(snapshot
                                      .data!.docs
                                      .elementAt(index)
                                      .get('id'))));
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(
                              snapshot.data!.docs
                                  .elementAt(index)
                                  .get('movieName'),
                              style: TextStyle(letterSpacing: 2),
                            ),
                            // children: [
                            //   Text(
                            //     snapshot.data!.docs
                            //         .elementAt(index)
                            //         .get('movieName'),
                            //     style: TextStyle(
                            //         color: MovieUtils.colorLight,
                            //         letterSpacing: 2),
                            //   ),
                            // ],

                            subtitle: Align(
                              alignment: Alignment.topLeft,
                              child: Chip(
                                  elevation: 5,
                                  backgroundColor: MovieUtils.colorThird,
                                  label: Text(
                                    (kk.length - 1).toString(),
                                    style:
                                        TextStyle(color: MovieUtils.colorLight),
                                  )),
                            ),
                          ),
                        ));
                  },
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

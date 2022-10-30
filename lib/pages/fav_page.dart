import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/pages/movies_page.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/services/database_service.dart';
import 'package:movie_app/widget/fav_page_list_view_widget.dart';

class FavPage extends StatefulWidget {
  MovieDetail? movieDetail;
  FavPage(this.movieDetail, {Key? key}) : super(key: key);

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    replyCountMain();
  }

  Future<void> createReply(String name, String reply, String id) async {
    await _databaseService.writeReplyOnMovie(name, reply, id);
  }

  Future<void> replyCountMain() async {
    int sayi =
        await _databaseService.replyCount(widget.movieDetail!.id.toString());

    if (sayi == 0 || sayi == null) {
      createReply(widget.movieDetail!.title!, "deneme",
          widget.movieDetail!.id.toString());
      print("CRATE REPLY ÇALIŞTI");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: MovieUtils.colorDark,
        child: StreamBuilder(
          stream: _databaseService
              .fetchMoviesFromFirebase(_authService.getCurrentUser()!),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: MovieUtils.colorLight,
                                borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.turn_left,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  color: MovieUtils.colorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: MovieUtils.colorLight,
                                borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.favorite,
                                  size: 48,
                                  color: MovieUtils.colorDark,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(height: MediaQuery.of(context).size.height - 800),
                    Container(
                      width: 200,
                      height: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          snapshot.data!.size.toString(),
                          style: TextStyle(
                              color: MovieUtils.colorDark, letterSpacing: 2),
                        )),
                      ),
                      decoration: BoxDecoration(
                          color: MovieUtils.colorLight,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context, index) {
                        return StreamBuilder<DocumentSnapshot>(
                            stream: _databaseService.readReplyOnMovie(snapshot
                                .data!.docs
                                .elementAt(index)
                                .get('id')
                                .toString()),
                            builder: (context, AsyncSnapshot snapshotReply) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => MovieDetailPage(
                                              movieID: snapshot.data!.docs
                                                  .elementAt(index)
                                                  .get('id')
                                                  .toString())));
                                },
                                child: FocusedMenuHolder(
                                  blurSize: 5,
                                  animateMenuItems: true,
                                  onPressed: () {},
                                  menuItems: [
                                    FocusedMenuItem(
                                        title: const Text("Replik yaz"),
                                        onPressed: () async {
                                          await _databaseService
                                              .writeRepliesOnMovie(
                                            "Osadasdasd",
                                            snapshot.data!.docs
                                                .elementAt(index)
                                                .get('id')
                                                .toString(),
                                          );
                                        }),
                                    FocusedMenuItem(
                                        title: const Text("Replikler"),
                                        onPressed: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => MoviesPage(
                                                      snapshot.data!.docs
                                                          .elementAt(index)
                                                          .get('id')
                                                          .toString())));
                                        }),
                                  ],
                                  child: FavPageListWidget(
                                    thumbnail: Image.network(snapshot.data!.docs
                                        .elementAt(index)
                                        .get('url')),
                                    title: snapshot.data!.docs
                                        .elementAt(index)
                                        .get('movieName'),
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

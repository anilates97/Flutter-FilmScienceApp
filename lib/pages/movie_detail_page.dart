import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/movie_app.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/fav_page.dart';
import 'package:movie_app/pages/signin_page.dart';

import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/services/database_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../widget/build_fragment_widget.dart';
import '../widget/containers_box_decoration_widget.dart';

class MovieDetailPage extends StatefulWidget {
  String movieID;
  double width = 180;
  MovieDetailPage({Key? key, required this.movieID}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  IconData icon = Icons.favorite_outline;
  final APIMovieServices _services = APIMovieServices();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  bool deger = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 1.2,
        width: double.infinity,
        color: const Color(0xFF256D85),
        child: FutureBuilder(
          future: _services.movieDetails(widget.movieID),
          builder: (context, AsyncSnapshot<MovieDetail> snapshot) {
            if (snapshot.hasData) {
              String str = genreList(snapshot.data!.genres!);
              String strCoverImage =
                  MovieUtils.IMAGE_PATH + snapshot.data!.posterPath!;
              String movieBack =
                  MovieUtils.IMAGE_PATH + snapshot.data!.backdropPath!;
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 5.1,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(movieBack),
                                fit: BoxFit.fill)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton(
                            alignment: Alignment.topLeft,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_sharp,
                              size: 35,
                              color: Colors.white,
                            )),
                      ),
                      Positioned(
                          right: 25,
                          top: 20,
                          child: IconButton(
                            icon: StreamBuilder<DocumentSnapshot>(
                                stream: _databaseService.fetchMovieFromFirebase(
                                    _authService.getCurrentUser()!,
                                    snapshot.data!.id.toString()),
                                builder: (context, snapFav) {
                                  if (snapFav.data == null) {
                                    print("snapshot fav: ${snapFav.data}");
                                    // if (snapFav.data!.get('fav') == false) {}
                                    // snapFav.data!.docs.forEach((element) {
                                    //   if (element.get('id') == snapshot.data!.id) {
                                    //     print(
                                    //         "ELEMENT ID:${element.get('id')} + ID :: ${snapshot.data!.id}");
                                    //     icon = Icons.favorite;
                                    //   } else {
                                    //     icon = Icons.favorite_outline;
                                    //   }
                                    // });
                                    return const Icon(
                                      Icons.favorite_outline,
                                      size: 32,
                                    );
                                  } else {
                                    if (snapFav.data!.exists) {
                                      return const Icon(
                                        Icons.favorite,
                                        size: 32,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.favorite_outline,
                                        size: 32,
                                      );
                                    }
                                  }
                                }),
                            onPressed: () async {
                              if (_authService.getCurrentUser() != null) {
                                deger = await _databaseService
                                    .isDuplicateUniqueName(snapshot.data!.id!,
                                        _authService.getCurrentUser()!);

                                if (!deger) {
                                  setState(() {
                                    _databaseService.addMovieToDatabase(
                                        snapshot.data!,
                                        strCoverImage,
                                        snapshot.data!.id.toString());
                                    _databaseService.updateFavInfoFromFirebase(
                                        _authService.getCurrentUser()!,
                                        snapshot.data!.id!);
                                    icon = Icons.favorite;
                                    var snackBar = SnackBar(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      elevation: 0,
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      content: AwesomeSnackbarContent(
                                        color: MovieUtils.colorDark,
                                        title: 'Başarılı',
                                        message: 'Film favorilere eklendi!',

                                        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                        contentType: ContentType.success,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                FavPage(snapshot.data)));
                                  });
                                } else {
                                  _databaseService.deleteMovieFromFirebase(
                                      _authService.getCurrentUser()!,
                                      snapshot.data!.id!.toString());
                                  var snackBar = SnackBar(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    elevation: 0,
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    content: AwesomeSnackbarContent(
                                      color: MovieUtils.colorDark,
                                      title: 'Başarılı',
                                      message: 'Film favorilerden kaldırıldı!',

                                      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                      contentType: ContentType.warning,
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              } else {
                                CoolAlert.show(
                                  onConfirmBtnTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => SignInPage()));
                                  },
                                  barrierDismissible: true,
                                  animType: CoolAlertAnimType.slideInDown,
                                  context: context,
                                  type: CoolAlertType.warning,
                                  text: "Lütfen önce giriş yapınız",
                                );
                              }
                            },
                            color: Colors.white,
                          ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: MovieUtils.colorLight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                snapshot.data!.title!,
                                style: TextStyle(
                                    color: MovieUtils.colorDark,
                                    letterSpacing: 3),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 275,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: MovieUtils.colorDark),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              children: [
                                Text(
                                  snapshot.data!.overview!,
                                  style: TextStyle(
                                    letterSpacing: 2,
                                    color: MovieUtils.colorLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerElements(
                          width: widget.width,
                          height: 30,
                          textColor: MovieUtils.colorDark,
                          containerColor: MovieUtils.colorLight,
                          movieText: "Film Türü"),
                      ContainerElements(
                          width: widget.width,
                          height: 30,
                          textColor: MovieUtils.colorLight,
                          containerColor: MovieUtils.colorDark,
                          movieText: str),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerElements(
                          width: widget.width,
                          height: 30,
                          textColor: MovieUtils.colorDark,
                          containerColor: MovieUtils.colorLight,
                          movieText: "Ülke"),
                      ContainerElements(
                          width: widget.width,
                          height: 30,
                          textColor: MovieUtils.colorLight,
                          containerColor: MovieUtils.colorDark,
                          movieText: snapshot.data!.productionCountries!.isEmpty
                              ? "-"
                              : snapshot.data!.productionCountries![0].name!),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerElements(
                          width: widget.width,
                          height: 30,
                          textColor: MovieUtils.colorDark,
                          containerColor: MovieUtils.colorLight,
                          movieText: "Yapım"),
                      ContainerElements(
                          width: widget.width,
                          height: 30,
                          textColor: MovieUtils.colorLight,
                          containerColor: MovieUtils.colorDark,
                          movieText:
                              snapshot.data!.releaseDate!.year.toString()),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 6),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: MovieUtils.colorDark),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Fragman",
                              style: TextStyle(
                                color: MovieUtils.colorLight,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                primary: MovieUtils.colorDark),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => FavPage(snapshot.data)));
                            },
                            child: Icon(
                              Icons.favorite,
                              size: 32,
                              color: MovieUtils.colorLight,
                            )),
                      )
                    ],
                  ),
                  BuildFragmentWidget(
                      widget.movieID, snapshot.data!.backdropPath!)
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    ));
  }

  String genreList(List<Genre> list) {
    String str = "";
    for (Genre genre in list) {
      str = "$str ${genre.name!}";
    }
    return str;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/application/movie_notifier.dart';
import 'package:movie_app/model/movie_app.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/pages/signin_page.dart';
import 'package:movie_app/pages/signup_page.dart';
import 'package:movie_app/repository/api_provider.dart';
import 'package:movie_app/services/auth_service.dart';

import '../repository/movie_repository.dart';
import '../services/api_services.dart';
import '../widget/home_page_grid_view_list.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<MovieModel> movieList = [];
  FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, (() {
      return ref.read(movieNotifierProvider.notifier).getMovies();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MovieUtils.colorDark,
          title: Text("Top Movies"),
          actions: [
            ElevatedButton(
                onPressed: () {
                  if (_authService.getCurrentUser() != null) {
                    _authService.signOut();
                    setState(() {});
                  } else {
                    setState(() {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SignInPage()));
                    });
                  }
                },
                style: ElevatedButton.styleFrom(primary: MovieUtils.colorLight),
                child: Text(
                  _authService.getCurrentUser() != null ? "Logout" : "Login",
                  style: TextStyle(color: MovieUtils.colorDark),
                ))
          ],
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(movieNotifierProvider);

            if (state is MovieInitial) {
              print("MovieInitial çalıştı");
              return Container();
            } else if (state is MovieLoading) {
              print("MovieLoading çalıştı");
              return buildLoading();
            } else if (state is MovieLoaded) {
              print("MovieLoaded çalıştı");
              return buildWidgetWithData(
                context,
                state.movies,
                ref,
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Widget buildLoading() {
    return const Center(
        child: CircularProgressIndicator(
      color: Colors.red,
    ));
  }

  Widget buildWidgetWithData(
      BuildContext context, List<Result> movies, WidgetRef ref) {
    int sayac = 1;
    return Column(
      children: [
        Container(
          color: const Color(0xFF256D85),
          height: MediaQuery.of(context).size.height - 200,
          child: GridView.builder(
            shrinkWrap: true,
            cacheExtent: 99999,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              String movieCover =
                  MovieUtils.IMAGE_PATH + movies[index].posterPath!;
              print("MOVIE IMAGE: $movieCover");
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MovieDetailPage(
                              movieID: movies[index].id.toString())));
                },
                child: MyCustomListTileGridView(
                  thumbnail: CachedNetworkImage(
                      fit: BoxFit.contain, imageUrl: movieCover),
                  title: movies[index].title!,
                ),
              );
            },
          ),
        ),
        Container(
          height: 72,
          color: MovieUtils.colorDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (APIMovieRepository.sayac > 1) {
                        APIMovieRepository.sayac--;
                      } else if (APIMovieRepository.sayac == 1) {
                        return;
                      }

                      // ignore: prefer_interpolation_to_compose_strings
                      print("SAYAÇ: " + APIMovieRepository.sayac.toString());
                      ref
                          .read(movieNotifierProvider.notifier)
                          .previousMovies(APIMovieRepository.sayac);
                    },
                    child: Container(
                      color: Colors.indigo,
                      height: 50,
                      width: 50,
                      child: const Icon(Icons.arrow_left,
                          size: 50, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      APIMovieRepository.sayac++;

                      // ignore: prefer_interpolation_to_compose_strings
                      print("SAYAÇ: " + APIMovieRepository.sayac.toString());
                      ref
                          .read(movieNotifierProvider.notifier)
                          .nextMovies(APIMovieRepository.sayac);
                    },
                    child: Container(
                      color: Colors.indigo,
                      height: 50,
                      width: 50,
                      child: const Icon(Icons.arrow_right,
                          size: 50, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: MovieUtils.colorLight),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      APIMovieRepository.sayac.toString(),
                      style:
                          TextStyle(color: MovieUtils.colorDark, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

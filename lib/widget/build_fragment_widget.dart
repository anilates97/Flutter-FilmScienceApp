import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/fragment.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildFragmentWidget extends StatefulWidget {
  String movieID;
  String backdropPath;
  BuildFragmentWidget(this.movieID, this.backdropPath, {Key? key})
      : super(key: key);

  @override
  State<BuildFragmentWidget> createState() => _BuildFragmentWidgetState();
}

class _BuildFragmentWidgetState extends State<BuildFragmentWidget> {
  APIMovieServices _movieServices = APIMovieServices();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: FutureBuilder(
        future: _movieServices.movieFragment(widget.movieID),
        builder: (context, AsyncSnapshot<List<ResultFragment>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Uri _url = Uri.parse(MovieUtils.VIDEO_YOUTUBE +
                          snapshot.data![index].key!);
                      _launchUrl(_url);
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black, blurRadius: 2)
                                    ],
                                    border: Border.all(
                                        width: 3, color: MovieUtils.colorDark)),
                                width: 300,
                                height: 150,
                                child: Image.network(
                                  MovieUtils.IMAGE_PATH + widget.backdropPath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.width / 7,
                              left: MediaQuery.of(context).size.width / 3,
                              child: Icon(
                                Icons.play_circle,
                                color: MovieUtils.colorLight,
                                size: 64,
                              ),
                            )
                          ],
                        ),
                        Text(
                          snapshot.data![index].name!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 2),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

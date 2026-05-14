import 'package:flutter/material.dart';
import 'package:movie_app/pages/replies_page.dart';

class MoviesPage extends StatelessWidget {
  final String movieID;
  MoviesPage(this.movieID, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepliesPage(movieID);
  }
}

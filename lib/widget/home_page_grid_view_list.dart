import 'package:flutter/material.dart';
import 'package:movie_app/api/utils.dart';

class MyCustomListTileGridView extends StatelessWidget {
  final Widget? thumbnail;
  final String title;
  final String? description;

  MyCustomListTileGridView({
    Key? key,
    required this.thumbnail,
    required this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Container(
        color: Colors.white70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: MovieUtils.colorDark,
                        boxShadow: [BoxShadow(spreadRadius: 2, blurRadius: 4)],
                        border:
                            Border.all(color: Color.fromARGB(255, 64, 9, 5))),
                    child: thumbnail!)),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white70),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              title,
                            ))),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

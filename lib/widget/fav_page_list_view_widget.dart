import 'package:flutter/material.dart';
import 'package:movie_app/api/utils.dart';

class FavPageListWidget extends StatelessWidget {
  final Widget? thumbnail;
  final String title;
  final String? description;

  FavPageListWidget({
    Key? key,
    required this.thumbnail,
    required this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    decoration: BoxDecoration(
                        color: MovieUtils.colorDark,
                        boxShadow: [BoxShadow(spreadRadius: 2, blurRadius: 4)],
                        border:
                            Border.all(color: Color.fromARGB(255, 64, 9, 5))),
                    child: thumbnail!),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width - 100,
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
                                  style: TextStyle(letterSpacing: 2),
                                ))),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

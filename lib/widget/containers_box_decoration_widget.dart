import 'package:flutter/cupertino.dart';

class ContainerElements extends StatelessWidget {
  Color textColor;
  Color containerColor;
  String movieText;
  double height;
  double width;
  ContainerElements(
      {Key? key,
      required this.height,
      required this.width,
      required this.textColor,
      required this.containerColor,
      required this.movieText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: containerColor),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Text(
                movieText,
                style: TextStyle(
                  letterSpacing: 2,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

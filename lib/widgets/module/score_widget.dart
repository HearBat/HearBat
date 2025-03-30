import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

enum ScoreType { score, average }

class ScoreWidget extends StatelessWidget {
  const ScoreWidget(
      {super.key,
        required this.context,
        required this.type,
        required this.correctAnswersCount,
        required this.subtitleText,
        required this.icon,
        required this.boxDecoration,
        required this.total});

  final BuildContext context;
  final ScoreType type;
  final String correctAnswersCount;
  final String subtitleText;
  final Icon icon;
  final BoxDecoration boxDecoration;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .90,
      height: MediaQuery.of(context).size.height * .1,
      margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
      padding: EdgeInsets.all(8.0),
      decoration: boxDecoration,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  switch (type) {
                    ScoreType.score => '$correctAnswersCount / $total',
                    ScoreType.average => '$correctAnswersCount%'
                  },
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: subtitleText.contains("Highest")
                          ? Colors.white
                          : Color.fromARGB(255, 7, 45, 78)),
                ),
                AutoSizeText(
                  subtitleText,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: subtitleText.contains("Highest")
                          ? Colors.white
                          : Color.fromARGB(255, 7, 45, 78)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: icon,
          ),
        ],
      ),
    );
  }
}

var gradientBoxDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 248, 213, 245),
      Color.fromARGB(255, 255, 192, 199),
      Color.fromARGB(255, 213, 177, 239),
    ],
  ),
  borderRadius: BorderRadius.circular(8.0),
  border: Border.all(
    color: Color.fromARGB(255, 7, 45, 78),
    width: 3.0,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withAlpha((0.5 * 255).toInt()),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 3),
    ),
  ],
);

var blueBoxDecoration = BoxDecoration(
  color: Color.fromARGB(255, 7, 45, 78),
  borderRadius: BorderRadius.circular(8.0),
  border: Border.all(
    color: Color.fromARGB(255, 7, 45, 78),
    width: 3.0,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withAlpha((0.5 * 255).toInt()),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 3),
    ),
  ],
);
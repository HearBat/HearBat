import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ChapterCardWidget extends StatefulWidget {
  final String chapterName;
  final int chapterNumber;
  final String image;
  final Widget destinationPage;

  const ChapterCardWidget({
    super.key,
    required this.chapterName,
    required this.chapterNumber,
    required this.image,
    required this.destinationPage,
  });

  @override
  State<ChapterCardWidget> createState() => _ChapterCardWidgetState();
}

class _ChapterCardWidgetState extends State<ChapterCardWidget> {
  double elevation = 5.0;

  void _navigateToChapter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget.destinationPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.9;
    final cardHeight = screenSize.height * 0.28;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => elevation = 1.0),
        onTapUp: (_) => setState(() {
          elevation = 5.0;
          _navigateToChapter(context);
        }),
        onTapCancel: () => setState(() => elevation = 5.0),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Card(
            elevation: elevation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: cardHeight * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    // blue box
                    child: Container(
                      height: cardHeight * 0.35,
                      color: Color.fromARGB(255, 7, 45, 78),
                      padding: EdgeInsets.only(
                          left: 16.0, top: 10.0, right: 16.0, bottom: 16.0),
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        widget.chapterName.toUpperCase(), //new
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math';

class HomeCardWidget extends StatefulWidget {
  final String cardText;
  final String description;
  final Widget destinationPage;
  final String image;

  const HomeCardWidget({
    super.key,
    required this.cardText,
    required this.description,
    required this.destinationPage,
    required this.image,
  });

  @override
  State<HomeCardWidget> createState() => _HomeCardWidgetState();
}

class _HomeCardWidgetState extends State<HomeCardWidget> {
  double elevation = 5.0;
  void _navigateToPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => widget.destinationPage,),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.9;
    final cardHeight = max((screenSize.height * 0.65) / 3, 200.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => elevation = 1.0),
      onTapUp: (_) => setState(() {
        elevation = 5.0;
        _navigateToPage(context);
      }),
      onTapCancel: () => setState(() => elevation = 5.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Card(
          elevation: elevation,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: cardWidth * 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        widget.cardText,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      AutoSizeText(
                        widget.description,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      widget.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

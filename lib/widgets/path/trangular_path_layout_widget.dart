import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import '../../pages/module_types/words/words_list_page.dart';
import '../../utils/data_service_util.dart';

class TriangularPathLayout extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double itemSize;
  final String chapter;

  const TriangularPathLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
    required this.chapter,
  });

  @override
  State<TriangularPathLayout> createState() => _TriangularPathLayoutState();
}

class _TriangularPathLayoutState extends State<TriangularPathLayout> {
  double elevation = 5.0;

  void _navigateToWordsList(BuildContext context,
      Map<String, Module> modules, String chapterName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              WordsList(modules: modules, chapterName: chapterName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Module> modules = DataService().getWordChapter(widget.chapter).modules;
    List<Widget> positionedItems = [];

    double layoutWidth = MediaQuery.of(context).size.width;
    double initialXOffset = (layoutWidth / 2) - 125;

    double xOffset = initialXOffset;
    double yOffset = 30;

    for (int i = 0; i < widget.itemCount; i++) {
      if (i % 2 == 0) {
        xOffset = initialXOffset;
      } else {
        xOffset = initialXOffset + 125;
      }
      positionedItems.add(_buildPositionedItem(
          context, widget.itemBuilder, xOffset, yOffset, i));
      yOffset += widget.itemSize + 60;
    }
    double totalHeight = yOffset;

    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => elevation = 1.0),
            onTapUp: (_) => setState(() {
              elevation = 5.0;
              _navigateToWordsList(
                  context, modules, widget.chapter.toUpperCase());
            }),
            onTapCancel: () => setState(() => elevation = 5.0),
            child: Container(
              margin: EdgeInsets.all(20),
              child: Material(
                color: Colors.white,
                elevation: elevation,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    'View Chapter Words',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
              height: totalHeight, child: Stack(children: positionedItems)),
        ],
      ),
    );
  }

  Positioned _buildPositionedItem(BuildContext context,
      IndexedWidgetBuilder itemBuilder, double left, double top, int index) {
    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: widget.itemSize,
        height: widget.itemSize,
        child: itemBuilder(context, index),
      ),
    );
  }
}

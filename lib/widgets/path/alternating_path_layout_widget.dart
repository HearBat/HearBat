import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'dart:math' as math;
import '../../pages/module_types/words/words_list_page.dart';
import '../../utils/data_service_util.dart';
import '../../utils/translations.dart';

class AlternatingPathLayout extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double itemSize;
  final String chapter;

  const AlternatingPathLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
    required this.chapter,
  });

  @override
  State<AlternatingPathLayout> createState() => _AlternatingPathLayoutState();
}

class _AlternatingPathLayoutState extends State<AlternatingPathLayout> {
  double elevation = 5.0;

  void _navigateToWordsList(
      BuildContext context, Map<String, Module> modules, String chapterName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              WordsList(modules: modules, chapterName: chapterName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Module> modules =
        DataService().getWordChapter(widget.chapter).modules;
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
                    AppLocale.alternatingPathViewChapterWords
                        .getString(context),
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

  Positioned _buildPositionedItem(
    BuildContext context,
    IndexedWidgetBuilder itemBuilder,
    double left,
    double top,
    int index,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: itemBuilder(context, index),
    );
  }
}

class ModuleProgressBar extends StatelessWidget {
  final int filledSections;
  final int totalSections;

  const ModuleProgressBar(
      {super.key, required this.filledSections, this.totalSections = 3});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -80), 
      child: CustomPaint(
        painter: _ProgressBarPainter(
          filledSections: filledSections,
          totalSections: totalSections,
        ),
        size: const Size(140, 50),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final int filledSections;
  final int totalSections;

  _ProgressBarPainter({
    required this.filledSections,
    required this.totalSections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = -75;
    final double radius = 120;

    final double startAngle = math.pi * 0.35;
    final double endAngle = math.pi - (math.pi * 0.35);
    final double totalArcAngle = endAngle - startAngle;
    final double sectionAngle = totalArcAngle / totalSections;
    final double gapAngle = math.pi / 180 * 2;

    for (int i = 0; i < totalSections; i++) {
      paint.color = (i >= totalSections - filledSections
          ? Color.fromARGB(255, 239, 255, 18)
          : Color.fromARGB(255, 71, 93, 113));

      final double currentAngle = startAngle + (i * sectionAngle);
      final double nextAngle = currentAngle + sectionAngle;

      final double adjustedCurrentAngle =
          currentAngle + (i > 0 ? gapAngle / 2 : 0);
      final double adjustedNextAngle =
          nextAngle - (i < totalSections - 1 ? gapAngle / 2 : 0);

      final Path sectionPath = Path();
      final double innerRadius = radius - 8;

      sectionPath.moveTo(
        centerX + innerRadius * math.cos(adjustedCurrentAngle),
        centerY + innerRadius * math.sin(adjustedCurrentAngle),
      );

      sectionPath.arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: innerRadius),
        adjustedCurrentAngle,
        adjustedNextAngle - adjustedCurrentAngle,
        false,
      );

      sectionPath.lineTo(
        centerX + radius * math.cos(adjustedNextAngle),
        centerY + radius * math.sin(adjustedNextAngle),
      );

      sectionPath.arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        adjustedNextAngle,
        -(adjustedNextAngle - adjustedCurrentAngle),
        false,
      );

      sectionPath.lineTo(
        centerX + innerRadius * math.cos(adjustedCurrentAngle),
        centerY + innerRadius * math.sin(adjustedCurrentAngle),
      );

      canvas.drawPath(sectionPath, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
// import 'dart:math'; // needed for arc bar

class SoundAlternatingPathLayout extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double itemSize;
  final double spacing;

  const SoundAlternatingPathLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
    required this.spacing,
  });

  @override
  State<SoundAlternatingPathLayout> createState() =>
      _SoundAlternatingPathLayoutState();
}

class _SoundAlternatingPathLayoutState
    extends State<SoundAlternatingPathLayout> {
  @override
  Widget build(BuildContext context) {
    List<Widget> positionedItems = [];

    double layoutWidth = MediaQuery.of(context).size.width;
    double initialXOffset = (layoutWidth / 2) - 125;

    double xOffset = initialXOffset;
    double yOffset = 30;

    // Special case for single module - matches first button position exactly
    if (widget.itemCount == 1) {
      return Stack(
        children: [
          Positioned(
            left: initialXOffset,
            top: yOffset,
            child: Column(
              children: [
                SizedBox(
                  width: widget.itemSize,
                  height: widget.itemSize,
                  child: widget.itemBuilder(context, 0),
                ),
                const SizedBox(height: 6),
                ModuleProgressBar(
                  filledSections: 1,
                  totalSections: 3,
                  // width: widget.itemSize,       // needed for arc bar
                  // height: widget.itemSize / 2,  // needed for arc bar
                ),
              ],
            ),
          ),
        ],
      );
    }

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
      child: SizedBox(
          height: totalHeight, child: Stack(children: positionedItems)),
    );
  }

  Positioned _buildPositionedItem(BuildContext context,
      IndexedWidgetBuilder itemBuilder, double left, double top, int index) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          SizedBox(
            width: widget.itemSize,
            height: widget.itemSize,
            child: itemBuilder(context, index),
          ),
          const SizedBox(height: 6),
          ModuleProgressBar(
            filledSections: 1,
            totalSections: 3,
            // width: widget.itemSize,      // needed for arc bar
            // height: widget.itemSize / 2, // needed for arc bar
          ),
        ],
      ),
    );
  }
}

// draws progress bar under
class ModuleProgressBar extends StatelessWidget {
  final int filledSections;
  final int totalSections;

  const ModuleProgressBar(
      {super.key, required this.filledSections, this.totalSections = 3});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProgressBarPainter(
        filledSections: filledSections,
        totalSections: totalSections,
      ),
      size: const Size(140, 8), // x (length of bar), y (height of each section)
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
    final double sectionWidth = size.width / totalSections;
    final double sectionHeight = size.height;

    final paint = Paint()..style = PaintingStyle.fill;
    // ..strokeCap = StrokeCap.butt;
    // ..strokeCap = StrokeCap.round;
    // ..strokeCap = StrokeCap.square;

    for (int i = 0; i < totalSections; i++) {
      paint.color = (i < filledSections
          ? Color.fromARGB(255, 98, 81, 162)
          : Color.fromARGB(255, 71, 93, 113));

      // positioning for each section
      final left = i * sectionWidth;

      // default rectangle
      final rect = Rect.fromLTRB(
        left + 2,
        -40,
        left + sectionWidth - 2,
        sectionHeight - 40,
        // Radius.circular(sectionHeight),
      );

      // rounded for start and end section
      final rrectLeft = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(sectionHeight),
        bottomLeft: Radius.circular(sectionHeight),
      );
      final rrectRight = RRect.fromRectAndCorners(
        rect,
        topRight: Radius.circular(sectionHeight),
        bottomRight: Radius.circular(sectionHeight),
      );

      // decide which rectangle type to draw
      if (i == 0) {
        canvas.drawRRect(rrectLeft, paint);
      } else if (i == totalSections - 1) {
        canvas.drawRRect(rrectRight, paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//******************************************************************** testing for arc progress bar ************************************************************

//   Positioned _buildPositionedItem(BuildContext context,
//       IndexedWidgetBuilder itemBuilder, double left, double top, int index) {
//     return Positioned(
//       left: left,
//       top: top,
//       child: Column(
//         children: [
//           SizedBox(
//             width: widget.itemSize,
//             height: widget.itemSize,
//             child: itemBuilder(context, index),
//           ),
//           const SizedBox(height: 6),
//           ModuleProgressBar(
//             filledSections: 1,
//             totalSections: 3,
//             width: widget.itemSize,
//             height: widget.itemSize / 2,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ModuleProgressBar extends StatelessWidget {
//   final int filledSections;
//   final int totalSections;
//   final double width;
//   final double height;

//   const ModuleProgressBar({
//     super.key,
//     required this.filledSections,
//     required this.totalSections,
//     required this.width,
//     required this.height,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Transform(
//       alignment: Alignment.center,
//       transform: Matrix4.rotationX(pi),
//       child: CustomPaint(
//         size: Size(width, height / 2),
//         painter: _ModuleProgressBarPainter(
//           filledSections: filledSections,
//           totalSections: totalSections,
//           width: width,
//           height: height,
//         ),
//       ),
//     );
//   }
// }

// class _ModuleProgressBarPainter extends CustomPainter {
//   final int filledSections;
//   final int totalSections;
//   final double width;
//   final double height;

//   _ModuleProgressBarPainter({
//     required this.filledSections,
//     required this.totalSections,
//     required this.width,
//     required this.height,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 8
//       ..strokeCap = StrokeCap.round;

//     final double startAngle = pi * 9 / 8; // Start from the left (180°)
//     final double sweep = pi * (2 - (9/8)); // Half ellipse
//     final double sectionsweep = sweep / totalSections;

//     for (int i = 0; i < totalSections; i++) {
//       paint.color =
//           i < filledSections 
//           ? Color.fromARGB(255, 98, 81, 162)
//           : Color.fromARGB(255, 71, 93, 113));

//       final double segStart = startAngle + i * sectionsweep;

//       final Path path = Path()
//         ..addArc(
//           Rect.fromCenter(
//             center: Offset(width / 2, height * 1.75),
//             width: width * 1.2,
//             height: height,
//           ),
//           segStart,
//           sectionsweep,
//         );

//       canvas.drawPath(path, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
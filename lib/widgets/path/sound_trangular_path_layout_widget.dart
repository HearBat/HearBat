import 'package:flutter/material.dart';

class SoundTriangularPathLayout extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double itemSize;
  final double spacing;

  const SoundTriangularPathLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
    required this.spacing,
  });

  @override
  State<SoundTriangularPathLayout> createState() =>
      _SoundTriangularPathLayoutState();
}

class _SoundTriangularPathLayoutState extends State<SoundTriangularPathLayout> {
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
            child: SizedBox(
              width: widget.itemSize,
              height: widget.itemSize,
              child: widget.itemBuilder(context, 0),
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
      child: SizedBox(
        width: widget.itemSize,
        height: widget.itemSize,
        child: itemBuilder(context, index),
      ),
    );
  }
}

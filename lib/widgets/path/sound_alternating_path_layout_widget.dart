import 'package:flutter/material.dart';

class SoundAlternatingPathLayout extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double itemSize;
  
  const SoundAlternatingPathLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemSize,
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

    // Remove the special case - treat single item the same as multiple
    
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
        height: totalHeight, 
        child: Stack(children: positionedItems)
      ),
    );
  }

  Positioned _buildPositionedItem(BuildContext context,
      IndexedWidgetBuilder itemBuilder, double left, double top, int index) {
    return Positioned(
      left: left,
      top: top,
      child: itemBuilder(context, index), 
    );
  }
}
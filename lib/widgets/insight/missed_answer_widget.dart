import 'package:flutter/material.dart';
import 'package:hearbat/utils/translations.dart';

class MissedAnswerWidget extends StatelessWidget {
  final String word;
  final int missCount;

  const MissedAnswerWidget({super.key, required this.word, required this.missCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add some padding for spacing
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the display box
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [ // Add a subtle shadow for better visual separation
            BoxShadow(
              color: Colors.grey.withAlpha((0.2 * 255).toInt()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between word and count
          children: [
            Text(
              word,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${AppLocale.missedAnswersPageMissed.getString(context)}: $missCount',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.red, // Highlight the miss count
              ),
            ),
          ],
        ),
      ),
    );
  }
}
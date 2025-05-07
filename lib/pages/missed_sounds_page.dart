import 'package:flutter/material.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';

import '../utils/translations.dart';

// Most Missed Sounds pop up page
class MissedSoundsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: AppLocale.insightsPageTitle.getString(context)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            AppLocale.missedSoundsPageMostMissedSounds.getString(context),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
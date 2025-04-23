import 'package:flutter/material.dart';
import 'package:hearbat/widgets/top_bar_widget.dart'; 

// Most Missed Words pop up page
class MissedWordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'INSIGHTS'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Most Missed Words',
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

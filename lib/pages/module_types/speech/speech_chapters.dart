import 'package:flutter/material.dart';
import '../../../utils/data_service_util.dart';
import '../../../utils/translations.dart';
import '../../../widgets/top_bar_widget.dart';
import '../../../widgets/chapter_card_widget.dart';
import 'speech_path.dart';

class SpeechChapters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> chapters = DataService().getSpeechChapters();

    return Scaffold(
      appBar: TopBar(
        title: AppLocale.speechChaptersPageTitle.getString(context),
        leadingIcon: Icons.west,
      ),
      body: ListView(
        children: [
          SizedBox(height: 10.0),
          ...List.generate(chapters.length, (index) {
            return ChapterCardWidget(
              chapterName: chapters[index]["name"]!,
              chapterNumber: index,
              image: chapters[index]["image"]!,
              destinationPage: SpeechPath(chapter: chapters[index]["name"]!),
            );
          }),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

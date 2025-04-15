import 'package:flutter/material.dart';
import 'music_path.dart';
import '../../../widgets/top_bar_widget.dart';
import '../../../widgets/chapter_card_widget.dart';

class MusicChapters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> chapters = [
      { "name": "Pitch Resolution",
        "image": "assets/visuals/HBSoundChapterOne.png",
      },
    ];

    return Scaffold(
      appBar: TopBar(
        title: "MUSIC CHAPTERS",
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
              destinationPage: MusicPath(chapter: chapters[index]["name"]!),
              showChapterPrefix: false,
            );
          }),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

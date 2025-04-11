import 'package:flutter/material.dart';
import 'word_path.dart';
import '../../../widgets/top_bar_widget.dart';
import '../../../widgets/chapter_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordChapters extends StatefulWidget {
  @override
  State<WordChapters> createState() => _WordChaptersState();
}

class _WordChaptersState extends State<WordChapters> {
  List<Map<String, String>> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String language = prefs.getString('languagePreference') ?? 'English';

    if (language == 'English') {
      chapters = [
        {
          "name": "Beginner Foundations",
          "image": "assets/visuals/HBWordsChapterOne.png",
        },
        {
          "name": "Intermediate Progress",
          "image": "assets/visuals/HB_WordsChapterTwo.png",
        },
        {
          "name": "Advanced Exploration",
          "image": "assets/visuals/HBWordsChapterThree.png",
        },
        {
          "name": "Proficient Application",
          "image": "assets/visuals/HBWordsChapterFour.png",
        },
        {
          "name": "Expert Mastery",
          "image": "assets/visuals/HBWordsChapterFive.png",
        },
      ];
    }

    setState(() {
      isLoading = false; // Update isLoading to false to render the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: "WORD",
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
              destinationPage: WordPath(chapter: chapters[index]["name"]!),
            );
          }),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

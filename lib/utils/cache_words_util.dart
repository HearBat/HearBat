import 'package:hearbat/utils/google_tts_util.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Utility for caching words and sentences for a module by downloading their audio using Google TTS
class CacheWordsUtil {
  final GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();
  bool _isHardMode = false;

  CacheWordsUtil() {
    _loadDifficultyPreference();
  }

  // Loads the difficulty preference to determine whether we are in Hard Mode.
  Future<void> _loadDifficultyPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isHardMode = prefs.getString('difficultyPreference') == 'Hard';
  }

  // Caches words from a module by downloading their audio using Google TTS.
  Future<void> cacheModuleWords(
      List<AnswerGroup> module, String voiceType) async {
    await _loadDifficultyPreference(); // Ensure we load the latest mode

    // Create a list to hold all the futures for the concurrent downloads
    List<Future> downloadFutures = [];

    for (var group in module) {
      List<Answer> answers = group.answers.map((answer) => answer).toList();
      for (var answer in answers) {
        String textToCache = answer.answer;

        // If in Hard Mode, modify the text before caching
        if (_isHardMode) {
          textToCache = "Please select ${answer.answer} as the answer";
        }

        // Instead of awaiting each download, add it to the list
        downloadFutures.add(
            googleTTSUtil.downloadMP3(textToCache, voiceType).catchError((e) {
          print("Error downloading $textToCache: $e");
        }));
      }
    }

    // Wait for all downloads to complete
    await Future.wait(downloadFutures);
  }
}

import 'package:hearbat/utils/google_tts_util.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Utility for caching words and sentences for a module by downloading their audio using Google TTS
class CacheWordsUtil {
  final GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();
  bool _isHardMode = false;
  static bool _isCaching = false;

  CacheWordsUtil() {
    _loadDifficultyPreference();
  }

  Future<void> _loadDifficultyPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isHardMode = prefs.getString('difficultyPreference') == 'Hard';
  }

  Future<void> cacheModuleWords(List<AnswerGroup> module, String voiceType) async {
    if (_isCaching) {
      print("Caching already in progress, skipping...");
      return;
    }
    
    _isCaching = true;
    
    try {
      await _loadDifficultyPreference();
      
      List<Future> downloadFutures = [];
      for (var group in module) {
        List<Answer> answers = group.answers.map((answer) => answer).toList();
        for (var answer in answers) {
          String textToCache = answer.answer;
          if (_isHardMode) {
            textToCache = "Please select ${answer.answer} as the answer";
          }
          downloadFutures.add(
              googleTTSUtil.downloadMP3(textToCache, voiceType).catchError((e) {
            print("Error downloading $textToCache: $e");
          }));
        }
      }
      await Future.wait(downloadFutures);
    } finally {
      _isCaching = false;
    }
  }
}


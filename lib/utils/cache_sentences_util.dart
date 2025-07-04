import 'package:hearbat/utils/google_tts_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CacheSentencesUtil {
  final GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();
  static bool _isCaching = false; 
  
  Future<void> cacheSentences(List<String> sentences) async {
    if (_isCaching) {
      print("Caching already in progress, skipping...");
      return;
    }
    
    _isCaching = true;
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String voiceType = prefs.getString('voicePreference') ?? 'en-US-Wavenet-D';
      
      List<Future> downloadFutures = [];
      
      for (var sentence in sentences) {
        downloadFutures.add(
          googleTTSUtil.downloadMP3(sentence, voiceType).catchError((e) {
            print("Error downloading $sentence: $e");
          }),
        );
      }
      
      await Future.wait(downloadFutures);
    } finally {
      _isCaching = false; 
    }
  }
}
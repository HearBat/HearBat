import 'package:hearbat/utils/google_tts_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CacheSentencesUtil {
  final GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();

  // Caches sentences as audio files using Google TTS.
  Future<void> cacheSentences(List<String> sentences) async {
    // Load the latest voice type from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String voiceType = prefs.getString('voicePreference') ?? 'en-US-Wavenet-D';

    // Create a list to hold all the futures for concurrent downloads
    List<Future> downloadFutures = [];

    for (var sentence in sentences) {
      downloadFutures.add(
        googleTTSUtil.downloadMP3(sentence, voiceType).catchError((e) {
          print("Error downloading $sentence: $e"); // Logs any download errors.
        }),
      );
    }

    // Wait for all downloads to complete
    await Future.wait(downloadFutures);
  }
}

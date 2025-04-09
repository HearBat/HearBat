import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/texttospeech/v1.dart' as tts;
import '../utils/config_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Utility for handling text-to-speech (TTS) using Google's API.
// This class downloads, caches, and plays synthesized speech audio.
class GoogleTTSUtil {
  final AudioPlayer audioPlayer = AudioPlayer();
  final Map<String, String> cache = {};

  bool _isHardMode = false;

  GoogleTTSUtil() {
    _loadDifficultyPreference();
    initialize();
  }

  Future<void> initialize() async {
    await audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    // Need this so that the audio doesn't get taken over from other audio players
    await audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));
  }

  // Loads the difficulty preference to determine whether we are in Hard Mode.
  Future<void> _loadDifficultyPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isHardMode = prefs.getString('difficultyPreference') == 'Hard';
  }

  // Loads the Google Cloud API key from the configuration manager.
  Future<String> _loadCredentials() async {
    String apiKey = ConfigurationManager().googleCloudAPIKey;
    return apiKey;
  }

  // Converts text to speech and plays the audio.
  // Downloads the MP3 file if it's not cached.
  Future<void> speak(String text, String voicetype, {bool isQuestion = false, bool hardModeEnabled = true}) async {
    // Check if this is the special accent preview.
    bool isAccentPreview = (text == "Hello this is how I sound");

    // If hard mode is enabled and it's a question, modify the spoken text.
    if (_isHardMode && !isAccentPreview && isQuestion && hardModeEnabled) {
      text = "Please select $text as the answer";
    }

    // Format filename based on context
    String filename = "${text.replaceAll(" ", "_")}_$voicetype.mp3";

    // Check if the audio is already cached.
    String? audioPath = cache[filename];

    if (audioPath != null && await File(audioPath).exists()) {
      await audioPlayer.play(DeviceFileSource(audioPath));
    } else {
      await downloadMP3(text, voicetype);

      // Delay to ensure the file is fully downloaded
      await Future.delayed(Duration(seconds: 1));

      // Update the cache after downloading
      audioPath = cache[filename];

      if (audioPath != null && await File(audioPath).exists()) {
        await audioPlayer.play(DeviceFileSource(audioPath));
      } else {
        throw Exception("Failed to download MP3 for: $text");
      }
    }
  }

  // Downloads MP3 files for the given text and stores them locally.
  Future<void> downloadMP3(String text, String voicetype) async {
    String dir = (await getTemporaryDirectory()).path;

    // Format filename based on context
    String filename = "${text.replaceAll(" ", "_")}_$voicetype.mp3";
    String filePath = "$dir/$filename";
    File file = File(filePath);

    // Skips download if the file already exists.
    if (await file.exists()) {
      cache[filename] = filePath;
      return;
    }

    http.Client client = http.Client();
    try {
      String jsonString = await _loadCredentials();
      var jsonCredentials = jsonDecode(jsonString);

      final accountCredentials =
      ServiceAccountCredentials.fromJson(jsonCredentials);
      AccessCredentials credentials =
      await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        [tts.TexttospeechApi.cloudPlatformScope],
        http.Client(),
      );

      String url = "https://texttospeech.googleapis.com/v1/text:synthesize";
      var body = json.encode({
        "audioConfig": {"audioEncoding": "MP3", "pitch": 0, "speakingRate": 1},
        "input": {"text": text},
        "voice": {"languageCode": voicetype.substring(0, 5), "name": voicetype}
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${credentials.accessToken.data}"
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        String audioBase64 = jsonData['audioContent'];

        // Decodes and saves the MP3 audio file.
        Uint8List bytes = base64Decode(audioBase64);
        await file.writeAsBytes(bytes);

        // Updates cache with the downloaded file path.
        cache[filename] = filePath;
      } else {
        throw Exception(
            "Failed to get a valid response from the API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in GoogleTTSUtil.downloadMP3: $e");
      throw Exception("Error occurred in GoogleTTSUtil.downloadMP3: $e");
    } finally {
      client.close();
    }
  }
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BackgroundNoiseUtil {
  static final AudioPlayer _backgroundAudioPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.loop);

  static bool isPlaying = false; //Track if audio currently playing
  static double volume = 0.3;
  static Timer? _previewTimer; //Track the timer for use in settings

  static Future<void> initialize() async {
    await _backgroundAudioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    // Need this so that the audio doesn't get taken over from other audio players
    await _backgroundAudioPlayer.setAudioContext(AudioContext(
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

  // Plays the saved background sound based on user preference.
  static Future<void> playSavedSound() async {
    if (isPlaying) {
      await stopSound();
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? backgroundSound = prefs.getString('backgroundSoundPreference');
    String? audioVolume = prefs.getString('audioVolumePreference');

    if (backgroundSound != null && backgroundSound != 'None') {
      isPlaying = true;
      String fileName = backgroundSound.replaceAll(' Sound', '').toLowerCase();
      await _adjustVolume(audioVolume);
      await _backgroundAudioPlayer.play(
        AssetSource("audio/background/$fileName.mp3"),
      );
    }
  }

  // Plays the saved background sound for a preview (3 seconds).
  static Future<void> playPreview() async {
    _previewTimer?.cancel(); // Cancel any existing preview timer
    await playSavedSound();

    _previewTimer = Timer(Duration(seconds: 3), () {
      stopSound();
    });
  }

  // Stops the currently playing background sound.
  static Future<void> stopSound() async {
    await _backgroundAudioPlayer.stop();
    isPlaying = false;
    _previewTimer?.cancel(); // Cancel the preview timer
    _previewTimer = null;
  }

  // Adjusts the volume level based on user preference.
  static Future<void> _adjustVolume(String? volumeLevel) async {
    switch (volumeLevel) {
      case 'Low':
        volume = 0.3;
      case 'Medium':
        volume = 0.7;
      case 'High':
        volume = 1.0;
      default:
        volume = 0.3;
    }
    _backgroundAudioPlayer.setVolume(volume);
  }
}

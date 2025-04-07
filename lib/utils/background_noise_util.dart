import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BackgroundNoiseUtil {
  static final AudioPlayer _backgroundAudioPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.loop);

  static bool _isPlaying = false; //Track if audio currently playing
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
        audioFocus: AndroidAudioFocus.gain,
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
    if (_isPlaying) {
      await stopSound();
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? backgroundSound = prefs.getString('backgroundSoundPreference');
    String? audioVolume = prefs.getString('audioVolumePreference');

    if (backgroundSound != null && backgroundSound != 'None') {
      _isPlaying = true;
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
    _isPlaying = false;
    _previewTimer?.cancel(); // Cancel the preview timer
    _previewTimer = null;
  }

  // Adjusts the volume level based on user preference.
  static Future<void> _adjustVolume(String? volumeLevel) async {
    switch (volumeLevel) {
      case 'Low':
        _backgroundAudioPlayer.setVolume(0.4);
      case 'Medium':
        _backgroundAudioPlayer.setVolume(0.7);  
      case 'High':
        _backgroundAudioPlayer.setVolume(1.0);
      default:
        _backgroundAudioPlayer.setVolume(0.4);
    }
  }
}

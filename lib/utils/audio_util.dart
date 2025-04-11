import 'package:audioplayers/audioplayers.dart';

class AudioUtil {
  static final AudioPlayer _soundAudioPlayer = AudioPlayer();
  static const double _defaultVolume = 1;

  static Future<void> initialize() async {
    await _soundAudioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    // Need this so that the audio doesn't get taken over from other audio players
    await _soundAudioPlayer.setAudioContext(AudioContext(
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

  // used for Sound modules, word modules use google_tts_util
  static Future<void> playSound(String audioFilePath) async {
    await _soundAudioPlayer.setVolume(_defaultVolume); // sets volume
    await _soundAudioPlayer.play(AssetSource(audioFilePath));
  }

  // Stops any currently playing audio.
  static Future<void> stop() async {
    await _soundAudioPlayer.stop();
  }
}

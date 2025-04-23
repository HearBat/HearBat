import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/audio_util.dart';
import 'package:hearbat/utils/cache_sentences_util.dart';
import 'package:hearbat/widgets/module/speech_module_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/google_tts_util.dart';
import '../module/module_widget.dart';
import '../module/pitch_resolution_exercise.dart';
import 'package:hearbat/utils/cache_words_util.dart';
import 'package:hearbat/utils/background_noise_util.dart';

// ignore_for_file: use_build_context_synchronously
class DifficultySelectionWidget extends StatefulWidget {
  final String moduleName;
  final String? chapter;
  final List<AnswerGroup> answerGroups;
  final bool isWord; //determines if TTS is used
  final bool displayDifficulty; //determines if difficulty setting is shown
  final bool displayVoice;
  final List<String>? sentences; // Speech module specific
  final String? voiceType; //Speech module specific

  DifficultySelectionWidget(
      {required this.moduleName, this.chapter, required this.answerGroups, required this.isWord,required this.displayDifficulty, required this.displayVoice, this.sentences, this.voiceType,});

  @override
  DifficultySelectionWidgetState createState() =>
      DifficultySelectionWidgetState();
}

class DifficultySelectionWidgetState extends State<DifficultySelectionWidget> {
  String _difficulty = 'Normal';
  final CacheWordsUtil cacheUtil = CacheWordsUtil();
  bool isCaching = false;
  String? _voiceType;


  List<String> voiceTypes = [
    "en-US-Studio-O",
    "en-GB-Neural2-C",
    "en-IN-Neural2-A",
    "en-AU-Neural2-C",
    "en-US-Studio-Q",
    "en-GB-Neural2-B",
    "en-IN-Neural2-B",
    "en-AU-Neural2-B",
  ];

  Map<String, String> voiceTypeTitles = {
    "en-US-Studio-O": "US Female",
    "en-GB-Neural2-C": "UK Female",
    "en-IN-Neural2-A": "IN Female",
    "en-AU-Neural2-C": "AU Female",
    "en-US-Studio-Q": "US Male",
    "en-GB-Neural2-B": "UK Male",
    "en-IN-Neural2-B": "IN Male",
    "en-AU-Neural2-B": "AU Male",
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadVoiceType();
    BackgroundNoiseUtil.initialize();
    AudioUtil.initialize();
  }

  void _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _difficulty = prefs.getString('difficultyPreference') ?? 'Normal';
    });
  }

  void _loadVoiceType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String language = prefs.getString('languagePreference') ?? 'English';
    setState(() {
      _voiceType = prefs.getString('voicePreference') ?? "en-US-Studio-O";
    });
  }

  void _updatePreference(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    _loadPreferences();
  }

  void _updateDifficulty(String? value) {
    setState(() {
      _difficulty = value!;
    });
    _updatePreference('difficultyPreference', _difficulty);
  }

  Future<void> _cacheAndNavigate(
      String moduleName, List<AnswerGroup> answerGroups) async {
    if (_voiceType == null) {
      print("Voice type not set. Unable to cache module words.");
      return;
    }

    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        dialogContext = ctx;
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    try {
      if (widget.isWord || widget.sentences == null) {
        await cacheUtil.cacheModuleWords(answerGroups, _voiceType!);
      }

      if (widget.sentences != null) {
        await CacheSentencesUtil().cacheSentences(widget.sentences!);
      }
    } catch (error) {
      print('Failed to cache content: $error');
    }

    if (!context.mounted) return;

    if (dialogContext != null && Navigator.canPop(dialogContext!)) {
      Navigator.of(dialogContext!).pop();
    }

    if (widget.chapter == "Pitch Resolution") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PitchResolutionExercise(answerGroups: answerGroups),
        ),
      );
    }
    else if (widget.sentences != null) {
      // Speech module
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpeechModuleWidget(
            chapter: moduleName,
            sentences: widget.sentences!,
            voiceType: widget.voiceType!,
          ),
        ),
      );
    }
    else {
      // Default module
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModuleWidget(
            title: moduleName,
            answerGroups: answerGroups,
            isWord: widget.isWord,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                //only display difficulty setting if requested
                if (widget.displayDifficulty)...[
                  Text(
                    "Difficulty",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "By completing modules, you can unlock difficulty levels",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        DifficultyOptionsWidget(
                          updateDifficultyCallback: (difficulty) =>
                              _updateDifficulty(difficulty),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
                if (widget.displayVoice)...[
                  Text(
                    "Voice",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        VoiceOptionsWidget(
                          updatePreferenceCallback: (preference, value) =>
                              _updatePreference(preference, value),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
                Text(
                  "Background Noise",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Background noises to add an extra challenge",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      SoundOptionsWidget(
                        updatePreferenceCallback: (preference, value) =>
                            _updatePreference(preference, value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  "Noise Intensity",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Choose the intensity of background noises",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      VolumeOptionsWidget(
                        updatePreferenceCallback: (preference, value) =>
                            _updatePreference(preference, value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _cacheAndNavigate(widget.moduleName, widget.answerGroups);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 7, 45, 78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(380, 50),
                    ),
                    child: Text(
                      'START EXERCISE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('difficultyPreference', 'Normal');
                        prefs.setString('backgroundSoundPreference', 'None');
                        prefs.setString('audioVolumePreference', 'Low');
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Theme
                          .of(context)
                          .scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: Color.fromARGB(255, 7, 45, 78),
                              width: 4.0)),
                      minimumSize: Size(380, 50),
                    ),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Color.fromARGB(255, 7, 45, 78),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceOptionsWidget extends StatefulWidget {
  final Function(String, String) updatePreferenceCallback;

  VoiceOptionsWidget({required this.updatePreferenceCallback});

  @override
  VoiceOptionsWidgetState createState() => VoiceOptionsWidgetState();
}

class VoiceOptionsWidgetState extends State<VoiceOptionsWidget> {
  String? _selectedVoicePreference;
  String? _randomVoiceSelectionPreference;
  final GoogleTTSUtil _googleTTSUtil = GoogleTTSUtil();
  List<String> voiceOptions = ["en-US-Studio-O", "en-US-Studio-Q"];

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedVoice = prefs.getString('voicePreference');
    if (savedVoice == null || savedVoice.isEmpty) {
      savedVoice = 'en-US-Studio-O';
      await prefs.setString('voicePreference', savedVoice);
    }

    switch (savedVoice) {
      case "en-US-Studio-O":
      case "en-US-Studio-Q":
        voiceOptions = ["en-US-Studio-O", "en-US-Studio-Q"];
      case "en-GB-Neural2-C":
      case "en-GB-Neural2-B":
        voiceOptions = ["en-GB-Neural2-C", "en-GB-Neural2-B"];
      case "en-IN-Neural2-A":
      case "en-IN-Neural2-B":
        voiceOptions = ["en-IN-Neural2-A", "en-IN-Neural2-B"];
      case "en-AU-Neural2-C":
      case "en-AU-Neural2-B":
        voiceOptions = ["en-AU-Neural2-C", "en-AU-Neural2-B"];
    }

    setState(() {
      _selectedVoicePreference = savedVoice;
      _randomVoiceSelectionPreference = "notRandom";
    });
  }

  void _handleTap(String value) {
    setState(() {
      if (value == 'isRandom') {
        _randomVoiceSelectionPreference = 'isRandom';
        widget.updatePreferenceCallback('randomVoiceSelectionPreference', value);
      } else {
        _randomVoiceSelectionPreference = 'notRandom';
        widget.updatePreferenceCallback('randomVoiceSelectionPreference', 'notRandom');
        _selectedVoicePreference = value;
        widget.updatePreferenceCallback('voicePreference', value);
        if (_selectedVoicePreference != null &&
            _selectedVoicePreference != 'random') {
          _googleTTSUtil.speak(
              "Hello this is how I sound", _selectedVoicePreference!);
        }
      }
    });
  }

  Widget _buildOption(String sound, String value) {
    bool isSelected = false;
    if(value == 'isRandom') {
      isSelected = _randomVoiceSelectionPreference == value;
    } else if(_randomVoiceSelectionPreference != 'isRandom') {
      isSelected = _selectedVoicePreference == value;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => _handleTap(value),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: ListTile(
              title: Text(
                sound,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Color.fromARGB(255, 7, 45, 78))
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildOption('Female', voiceOptions[0]),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('Male', voiceOptions[1]),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('Random', 'isRandom'),
      ],
    );
  }
}

class SoundOptionsWidget extends StatefulWidget {
  final Function(String, String) updatePreferenceCallback;

  SoundOptionsWidget({required this.updatePreferenceCallback});

  @override
  SoundOptionsWidgetState createState() => SoundOptionsWidgetState();
}

class SoundOptionsWidgetState extends State<SoundOptionsWidget> {
  String _selectedSound = 'None';

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  @override
  void dispose() {
    BackgroundNoiseUtil.stopSound();
    super.dispose();
  }

  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedSound = prefs.getString('backgroundSoundPreference');
    if (savedSound != null) {
      setState(() {
        _selectedSound = savedSound;
      });
      if (savedSound != "None") {
        BackgroundNoiseUtil.playPreview();
      }
    }
  }

  Future<void> _handleTap(String value) async {
    setState(() {
      _selectedSound = value;
      widget.updatePreferenceCallback('backgroundSoundPreference', value);
    });

    //Plays the selected background noise for 3 seconds as a preview
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedSound = prefs.getString('backgroundSoundPreference');

    if (selectedSound != null && selectedSound != "None") {
      BackgroundNoiseUtil.playPreview();
    }
  }

  Widget _buildOption(String sound, String value) {
    bool isSelected = _selectedSound == value;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => _handleTap(value),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: ListTile(
              title: Text(
                sound,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Color.fromARGB(255, 7, 45, 78))
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildOption('None', 'None'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('Rain', 'Rain Sound'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('Coffee Shop', 'Shop Sound'),
      ],
    );
  }
}

class VolumeOptionsWidget extends StatefulWidget {
  final Function(String, String) updatePreferenceCallback;

  VolumeOptionsWidget({required this.updatePreferenceCallback});

  @override
  VolumeOptionsWidgetState createState() => VolumeOptionsWidgetState();
}

class VolumeOptionsWidgetState extends State<VolumeOptionsWidget> {
  String _selectedVolume = 'Low'; // Default selected value

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  @override
  void dispose() {
    BackgroundNoiseUtil.stopSound();
    super.dispose();
  }

  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedVolume = prefs.getString('audioVolumePreference');
    if (savedVolume != null) {
      setState(() {
        _selectedVolume = savedVolume;
      });
    }
  }

  Future<void> _handleTap(String value) async {
    setState(() {
      _selectedVolume = value;
      widget.updatePreferenceCallback('audioVolumePreference', value);
    });

    // Play the selected background noise for 3 seconds as a preview
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedSound = prefs.getString('backgroundSoundPreference');

    if (selectedSound != null && selectedSound != "None") {
      BackgroundNoiseUtil.playPreview();
    }
  }

  Widget _buildOption(String volume) {
    bool isSelected = _selectedVolume == volume;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => _handleTap(volume),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: ListTile(
              title: Text(
                volume,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Color.fromARGB(255, 7, 45, 78))
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildOption('Low'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('Medium'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('High'),
      ],
    );
  }
}

class DifficultyOptionsWidget extends StatefulWidget {
  final Function(String) updateDifficultyCallback;

  DifficultyOptionsWidget({required this.updateDifficultyCallback});

  @override
  DifficultyOptionsWidgetState createState() => DifficultyOptionsWidgetState();
}

class DifficultyOptionsWidgetState extends State<DifficultyOptionsWidget> {
  String _selectedDifficulty = 'Normal';

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDifficulty = prefs.getString('difficultyPreference');
    if (savedDifficulty != null) {
      _selectedDifficulty = savedDifficulty;
    }
  }

  void _handleTap(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      widget.updateDifficultyCallback(difficulty);
    });
  }

  Widget _buildOption(String difficulty) {
    bool isSelected = _selectedDifficulty == difficulty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => _handleTap(difficulty),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: ListTile(
              title: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Color.fromARGB(255, 7, 45, 78))
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildOption('Normal'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('Hard'),
      ],
    );
  }
}
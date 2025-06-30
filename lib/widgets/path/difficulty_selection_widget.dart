import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/audio_util.dart';
import 'package:hearbat/utils/cache_sentences_util.dart';
import 'package:hearbat/widgets/module/speech_module_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/google_tts_util.dart';
import '../../utils/translations.dart';
import '../module/module_widget.dart';
import '../module/pitch_resolution_exercise.dart';
import 'package:hearbat/utils/cache_words_util.dart';
import 'package:hearbat/utils/background_noise_util.dart';

// ignore_for_file: use_build_context_synchronously
class DifficultySelectionWidget extends StatefulWidget {
  final String moduleName;
  final String exerciseType;
  final String? chapter;
  final List<AnswerGroup> answerGroups;
  final bool isWord; //determines if TTS is used
  final bool displayDifficulty; //determines if difficulty setting is shown
  final bool displayVoice;
  final List<String>? sentences; // Speech module specific

  DifficultySelectionWidget({
    required this.moduleName,
    required this.exerciseType,
    this.chapter,
    required this.answerGroups,
    required this.isWord,
    required this.displayDifficulty,
    required this.displayVoice,
    this.sentences,
  });

  @override
  DifficultySelectionWidgetState createState() =>
      DifficultySelectionWidgetState();
}

class DifficultySelectionWidgetState extends State<DifficultySelectionWidget> {
  String _difficulty = 'Normal';
  final CacheWordsUtil cacheUtil = CacheWordsUtil();
  bool isCaching = false;
  String? _voiceType;

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
    _loadVoiceType();
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
  bool needsToShowDialog = false;

  if (widget.isWord || widget.sentences == null) {
    needsToShowDialog = await _needsWordCaching(answerGroups, _voiceType!);
  } else if (widget.sentences != null) {
    needsToShowDialog = await _needsSentenceCaching(widget.sentences!);
  }

  if (needsToShowDialog) {
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
              Text(AppLocale.generalLoading.getString(context)),
            ],
          ),
        );
      },
    );
  }

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

  if (needsToShowDialog && dialogContext != null && Navigator.canPop(dialogContext!)) {
    Navigator.of(dialogContext!).pop();
  }

  if (widget.exerciseType == "music") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PitchResolutionExercise(
          title: "${widget.chapter ?? 'Pitch'} ${widget.moduleName}",
          answerGroups: answerGroups),
      ),
    );
  }
  else if (widget.sentences != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeechModuleWidget(
          title: "${widget.chapter ?? 'Speech'} ${widget.moduleName}",
          sentences: widget.sentences!,
          voiceType: _voiceType!,
        ),
      ),
    );
  }
  else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleWidget(
          title: "${widget.chapter ?? 'Custom'} ${widget.moduleName}",
          type: widget.exerciseType,
          answerGroups: answerGroups,
          isWord: widget.isWord,
        ),
      ),
    );
  }
}

Future<bool> _needsWordCaching(List<AnswerGroup> answerGroups, String voiceType) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isHardMode = prefs.getString('difficultyPreference') == 'Hard';
  
  String dir = (await getTemporaryDirectory()).path;
  
  for (var group in answerGroups) {
    for (var answer in group.answers) {
      String textToCache = answer.answer;
      if (isHardMode) {
        textToCache = "Please select ${answer.answer} as the answer";
      }
      
      String filename = "${textToCache.replaceAll(" ", "_")}_$voiceType.mp3";
      String filePath = "$dir/$filename";
      File file = File(filePath);
      
      if (!await file.exists()) {
        return true;
      }
    }
  }
  return false; 
}

Future<bool> _needsSentenceCaching(List<String> sentences) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String voiceType = prefs.getString('voicePreference') ?? 'en-US-Wavenet-D';
  
  String dir = (await getTemporaryDirectory()).path;
  
  for (var sentence in sentences) {
    String filename = "${sentence.replaceAll(" ", "_")}_$voiceType.mp3";
    String filePath = "$dir/$filename";
    File file = File(filePath);
    
    if (!await file.exists()) {
      return true;
    }
  }
  return false;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              if (widget.displayDifficulty)...[
                Text(
                  AppLocale.selectionPageDifficultyTitle.getString(context),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocale.selectionPageDifficultySubtitle.getString(context),
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
                SizedBox(height: 30.0),
              ],
              if (widget.displayVoice)...[
                Text(
                  AppLocale.selectionPageVoiceTitle.getString(context),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocale.selectionPageVoiceSubtitle.getString(context),
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
                      VoiceOptionsWidget(
                        updatePreferenceCallback: (preference, value) =>
                            _updatePreference(preference, value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
              ],
              Text(
                AppLocale.selectionPageBackgroundTitle.getString(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocale.selectionPageBackgroundSubtitle.getString(context),
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
              SizedBox(height: 30.0),
              Text(
                AppLocale.selectionPageIntensityTitle.getString(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocale.selectionPageIntensitySubtitle.getString(context),
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
              Spacer(),
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
                    AppLocale.selectionPageStart.getString(context),
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
                    AppLocale.generalCancel.getString(context),
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
      case "vi-VN-Standard-A":
      case "vi-VN-Standard-B":
        voiceOptions = ["vi-VN-Standard-A", "vi-VN-Standard-B"];

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
              AppLocale.generalAccentPreview.getString(context), _selectedVoicePreference!);
        }
      }
    });
  }

  Widget _buildOption(String display, String value, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = false;
    if(value == 'isRandom') {
      isSelected = _randomVoiceSelectionPreference == value;
    } else if(_randomVoiceSelectionPreference != 'isRandom') {
      isSelected = _selectedVoicePreference == value;
    }
    return InkWell(
      onTap: () => _handleTap(value),
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? Color.fromARGB(255, 7, 45, 78) : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(6.0) : Radius.zero,
              right: isLast ? const Radius.circular(6.0) : Radius.zero,
            )
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Center(
          child: Text(
            display,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Color.fromARGB(255, 7, 45, 78),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildOption(AppLocale.selectionPageVoiceFemale.getString(context), voiceOptions[0], isFirst: true),
        ),
        Expanded(
          child:  _buildOption(AppLocale.selectionPageVoiceMale.getString(context), voiceOptions[1]),
        ),
        Expanded(
          child: _buildOption(AppLocale.selectionPageVoiceRandom.getString(context), 'isRandom', isLast: true),
        ),
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

  Widget _buildOption(String display, String value, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = _selectedSound == value;
    return InkWell(
      onTap: () => _handleTap(value),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 7, 45, 78) : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(6.0) : Radius.zero,
            right: isLast ? const Radius.circular(6.0) : Radius.zero,
          )
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Center(
          child: Text(
            display,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Color.fromARGB(255, 7, 45, 78),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildOption(AppLocale.selectionPageBackgroundNone.getString(context), 'None', isFirst: true),
        ),
        Expanded(
          child: _buildOption(AppLocale.selectionPageBackgroundRain.getString(context), 'Rain Sound'),
        ),
        Expanded(
          child: _buildOption(AppLocale.selectionPageBackgroundCoffee.getString(context), 'Shop Sound', isLast: true),
        ),
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

  Future<void> _handleTap(String volume) async {
    setState(() {
      _selectedVolume = volume;
      widget.updatePreferenceCallback('audioVolumePreference', volume);
    });

    // Play the selected background noise for 3 seconds as a preview
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedSound = prefs.getString('backgroundSoundPreference');

    if (selectedSound != null && selectedSound != "None") {
      BackgroundNoiseUtil.playPreview();
    }
  }

  Widget _buildOption(String display, String value, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = _selectedVolume == value;
    return InkWell(
      onTap: () => _handleTap(value),
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? Color.fromARGB(255, 7, 45, 78) : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(6.0) : Radius.zero,
              right: isLast ? const Radius.circular(6.0) : Radius.zero,
            )
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Center(
          child: Text(
            display,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Color.fromARGB(255, 7, 45, 78),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildOption(AppLocale.selectionPageIntensityLow.getString(context), 'Low', isFirst: true ),
        ),
        Expanded(
          child: _buildOption(AppLocale.selectionPageIntensityMedium.getString(context), 'Medium'),
        ),
        Expanded(
          child: _buildOption(AppLocale.selectionPageIntensityHigh.getString(context), 'High', isLast: true),
        ),
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

  Widget _buildOption(String display, String value, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = _selectedDifficulty == value;
    return InkWell(
      onTap: () => _handleTap(value),
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? Color.fromARGB(255, 7, 45, 78) : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(6.0) : Radius.zero,
              right: isLast ? const Radius.circular(6.0) : Radius.zero,
            )
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Center(
          child: Text(
            display,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Color.fromARGB(255, 7, 45, 78),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildOption(AppLocale.selectionPageDifficultyNormal.getString(context), 'Normal', isFirst: true),
        ),
        Expanded(
          child:  _buildOption(AppLocale.selectionPageDifficultyHard.getString(context), 'Hard', isLast: true),
        ),
      ],
    );
  }
}
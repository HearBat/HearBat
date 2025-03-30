import 'package:flutter/material.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '../utils/cache_util.dart';
import '../utils/google_tts_util.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final GoogleTTSUtil _googleTTSUtil = GoogleTTSUtil();
  bool isCaching = false;
  AudioPlayer audioPlayer = AudioPlayer();
  String selectedLanguage = 'English';
  String selectedCorrectFeedback = 'on';
  String selectedWrongFeedback = 'on';

  List<String> voiceTypes = [
    "en-US-Studio-O",
    // "en-US-Neural2-C",
    "en-GB-Neural2-C",
    "en-IN-Neural2-A",
    "en-AU-Neural2-C",
    "en-US-Studio-Q",
    // "en-US-Neural2-D",
    "en-GB-Neural2-B",
    "en-IN-Neural2-B",
    "en-AU-Neural2-B",
  ];

  Map<String, String> voiceTypeTitles = {
    "en-US-Studio-O": "US Female",
    //"en-US-Neural2-C": "US2 Female",
    "en-GB-Neural2-C": "UK Female",
    "en-IN-Neural2-A": "IN Female",
    "en-AU-Neural2-C": "AU Female",
    "en-US-Studio-Q": "US Male",
    // "en-US-Neural2-D": "US2 Male",
    "en-GB-Neural2-B": "UK Male",
    "en-IN-Neural2-B": "IN Male",
    "en-AU-Neural2-B": "AU Male",
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _cacheVoiceTypes();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('languagePreference') ?? 'English';
    });
  }

  void _updatePreference(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    _loadPreferences();
  }

  Future<void> _cacheVoiceTypes() async {
    setState(() {
      isCaching = true;
    });
    String phraseToCache = "Hello this is how I sound";
    List<Future> downloadFutures = [];
    for (String voiceType in voiceTypes) {
      downloadFutures.add(_googleTTSUtil
          .downloadMP3(phraseToCache, voiceType)
          .catchError((e) {}));
    }
    await Future.wait(downloadFutures);
    setState(() {
      isCaching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'SETTINGS',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Language",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        LanguageOptionsWidget(
                          updatePreferenceCallback: _updatePreference,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Feedback Sound",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        FeedbackOptionsWidget(
                          updatePreferenceCallback: _updatePreference,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Voice Select",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Color.fromARGB(255, 7, 45, 78), width: 4.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        VoiceOptionsWidget(
                          updatePreferenceCallback: _updatePreference,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            ClearCacheWidget(),
          ],
        ),
      ),
    );
  }
}

// Handles feedback settings/display
class FeedbackOptionsWidget extends StatefulWidget {
  final Function(String, String) updatePreferenceCallback;

  FeedbackOptionsWidget({required this.updatePreferenceCallback});

  @override
  FeedbackOptionsWidgetState createState() => FeedbackOptionsWidgetState();
}


class FeedbackOptionsWidgetState extends State<FeedbackOptionsWidget> {
  String _selectedFeedback = "On";

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  // Load user preferences for feedback settings
  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedFeedback = prefs.getString('feedbackPreference');

    if (savedFeedback != null) {
      _selectedFeedback = savedFeedback;
    }
  }

  // Uses the passed feedbackKey to determine which setting the user wants to modify
  void _handleTap(String feedback) async {
    setState(() {
        _selectedFeedback = feedback;
        widget.updatePreferenceCallback("feedbackPreference", _selectedFeedback);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('feedbackPreference', _selectedFeedback);
  }

 Widget _buildOption(String feedback) {
    bool isSelected = _selectedFeedback == feedback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => _handleTap(feedback),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: ListTile(
              title: Text(
                feedback,
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
        _buildOption('Off'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption('On'),
      ],
    );
  }
}

class LanguageOptionsWidget extends StatefulWidget {
  final Function(String, String) updatePreferenceCallback;

  LanguageOptionsWidget({required this.updatePreferenceCallback});

  @override
  LanguageOptionsWidgetState createState() => LanguageOptionsWidgetState();
}

class LanguageOptionsWidgetState extends State<LanguageOptionsWidget> {
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('languagePreference');
    if (savedLanguage == null || savedLanguage.isEmpty) {
      savedLanguage = 'English';
      await prefs.setString('languagePreference', savedLanguage);
    }
    setState(() {
      _selectedLanguage = savedLanguage!;
    });
  }

  void _handleTap(String value) {
    setState(() {
      _selectedLanguage = value;
      widget.updatePreferenceCallback('languagePreference', value);
    });
  }

  Widget _buildOption(String language, String value, String assetName) {
    bool isSelected = _selectedLanguage == value;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => _handleTap(value),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: ListTile(
            leading: Image.asset(
              assetName,
              width: 30,
              height: 20,
            ),
            title: Text(
              language,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildOption('English', 'English', 'assets/visuals/us_flag.png'),
        // Divider(
        //   color: Color.fromARGB(255, 7, 45, 78),
        //   thickness: 3,
        //   indent: 20,
        //   endIndent: 20,
        // ),
        // _buildOption(
        //     'Vietnamese', 'Vietnamese', 'assets/visuals/vietnam_flag.png'),
      ],
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
  final GoogleTTSUtil _googleTTSUtil = GoogleTTSUtil();
  List<String> voiceTypes = [
    "en-US-Studio-O", // US Female
    "en-US-Studio-Q", // US Male
    "en-GB-Neural2-C", // UK Female
    "en-GB-Neural2-B", // UK Male
    "en-IN-Neural2-A", // IN Female
    "en-IN-Neural2-B", // IN Male
    "en-AU-Neural2-C", // AU Female
    "en-AU-Neural2-B", // AU Male
  ];

  Map<String, String> voiceTypeTitles = {
    "en-US-Studio-O": "American Female",
    "en-US-Studio-Q": "American Male",
    "en-GB-Neural2-C": "English Female",
    "en-GB-Neural2-B": "English Male",
    "en-IN-Neural2-A": "Indian Female",
    "en-IN-Neural2-B": "Indian Male",
    "en-AU-Neural2-C": "Australian Female",
    "en-AU-Neural2-B": "Australian Male",
  };

  @override
  void initState() {
    super.initState();
    _loadSavedPreference();
  }

  void _loadSavedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedVoice = prefs.getString('voicePreference');
    if (savedVoice == null || savedVoice.isEmpty) {
      savedVoice = 'en-US-Studio-O';
      await prefs.setString('voicePreference', savedVoice);
    }
    setState(() {
      _selectedVoicePreference = savedVoice;
    });
  }

  void _handleTap(String value) {
    setState(() {
      _selectedVoicePreference = value;
      widget.updatePreferenceCallback('voicePreference', value);
      if (_selectedVoicePreference != null) {
        _googleTTSUtil.speak(
            "Hello this is how I sound", _selectedVoicePreference!);
      }
    });
  }

  Widget _buildOption(String title, String value) {
    bool isSelected = _selectedVoicePreference == value;
    return ListTile(
      onTap: () => _handleTap(value),
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Color.fromARGB(255, 7, 45, 78))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> voiceOptionWidgets = [];
    for (int i = 0; i < voiceTypes.length; i++) {
      voiceOptionWidgets.add(
          _buildOption(voiceTypeTitles[voiceTypes[i]] ?? "", voiceTypes[i]));
      if (i < voiceTypes.length - 1) {
        voiceOptionWidgets.add(Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ));
      }
    }

    return Column(
      children: voiceOptionWidgets,
    );
  }
}

class ClearCacheWidget extends StatefulWidget {
  @override
  ClearCacheWidgetState createState() => ClearCacheWidgetState();
}

class ClearCacheWidgetState extends State<ClearCacheWidget> {
  String _sizeText = "Fetching...";

  @override
  void initState() {
    super.initState();
    _fetchSize();
  }

  Future<void> _fetchSize() async {
    final units = ["B", "KiB", "MiB", "GiB"];

    // Convert size to largest unit
    double size = (await getCacheSize()).toDouble();
    int unit = 0;
    while (size >= 1024) {
      size /= 1024;
      unit++;
    }

    setState(() {
      _sizeText = "${size.toStringAsFixed(2)} ${units[unit]}";
    });
  }

  Future<void> _handlePress() async {
    await clearCache();
    await _fetchSize();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            _handlePress();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 7, 45, 78),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(380, 50),
          ),
          child: Text(
            "CLEAR CACHE ($_sizeText)",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

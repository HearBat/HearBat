import 'package:flutter/material.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import '../utils/cache_util.dart';
import '../utils/data_service_util.dart';
import '../utils/google_tts_util.dart';
import '../utils/translations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
  bool _hasInitialized = false;

  Map<String, List<String>> voiceTypesMap = {
    'English': [
      "en-US-Studio-O",
      "en-GB-Neural2-C",
      "en-IN-Neural2-A",
      "en-AU-Neural2-C",
      "en-US-Studio-Q",
      "en-GB-Neural2-B",
      "en-IN-Neural2-B",
      "en-AU-Neural2-B",
    ],
    'Vietnamese': ["vi-VN-Standard-A", "vi-VN-Standard-B"],
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _cacheVoiceTypes();
    }
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
    if (key == 'languagePreference' && value != selectedLanguage) {
      _cacheVoiceTypes();
    }
  }

  Future<void> _cacheVoiceTypes() async {
    setState(() {
      isCaching = true;
    });
    String phraseToCache = AppLocale.generalAccentPreview.getString(context);
    List<Future> downloadFutures = [];
    List<String>? voiceTypes = voiceTypesMap[selectedLanguage];
    for (String voiceType in voiceTypes!) {
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
        title: AppLocale.settingsPageTitle.getString(context),
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
                    AppLocale.settingsPageLanguageTitle.getString(context),
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
                    AppLocale.settingsPageFeedbackTitle.getString(context),
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
                    AppLocale.settingsPageVoiceTitle.getString(context),
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
  String _selectedFeedback = "Off";

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

  Widget _buildOption(String display, String value, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = _selectedFeedback == value;
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
          child: _buildOption(AppLocale.settingsPageFeedbackOff.getString(context), 'Off', isFirst: true),
        ),
        Expanded(
          child: _buildOption(AppLocale.settingsPageFeedbackOn.getString(context), 'On', isLast: true),
        ),
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

  final Map<String, String> defaultVoiceTypes = {
    'English': "en-US-Studio-O", // US Female
    'Vietnamese': "vi-VN-Standard-A",
  };

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
      switch (value) {
        case 'English':
          localization.translate('en');
          widget.updatePreferenceCallback('voicePreference', "en-US-Studio-O");
          DataService().loadJsonLanguageSpecific();
        case 'Vietnamese':
          localization.translate('vi');
          widget.updatePreferenceCallback(
              'voicePreference', "vi-VN-Standard-A");
          DataService().loadJsonLanguageSpecific();
      }
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
        _buildOption(AppLocale.settingsPageLanguageEnglish.getString(context),
            'English', 'assets/visuals/us_flag.png'),
        Divider(
          color: Color.fromARGB(255, 7, 45, 78),
          thickness: 3,
          indent: 20,
          endIndent: 20,
        ),
        _buildOption(
            AppLocale.settingsPageLanguageVietnamese.getString(context),
            'Vietnamese',
            'assets/visuals/vietnam_flag.png'),
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
  late List<String> voiceTypes;
  late Map<String, String> voiceTypeTitles;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadSavedPreference();
    } else {
      _loadTranslation();
    }
  }

  void _loadSavedPreference() async {
    _loadTranslation();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedVoice = prefs.getString('voicePreference');
    if (savedVoice == null || savedVoice.isEmpty || !voiceTypes.contains(savedVoice)) {
      savedVoice = voiceTypes[0];
      await prefs.setString('voicePreference', savedVoice);
    }
    setState(() {
      _selectedVoicePreference = savedVoice;
    });
  }

  void _loadTranslation() {
    Locale? locale = localization.currentLocale;
    String? languageCode = locale?.languageCode;
    switch (languageCode) {
      case 'en':
        voiceTypes = [
          "en-US-Studio-O", // US Female
          "en-US-Studio-Q", // US Male
          "en-GB-Neural2-C", // UK Female
          "en-GB-Neural2-B", // UK Male
          "en-IN-Neural2-A", // IN Female
          "en-IN-Neural2-B", // IN Male
          "en-AU-Neural2-C", // AU Female
          "en-AU-Neural2-B", // AU Male
        ];
        voiceTypeTitles = {
          "en-US-Studio-O": AppLocale.settingsPageVoiceUSFemale.getString(context),
          "en-US-Studio-Q": AppLocale.settingsPageVoiceUSMale.getString(context),
          "en-GB-Neural2-C": AppLocale.settingsPageVoiceUKFemale.getString(context),
          "en-GB-Neural2-B": AppLocale.settingsPageVoiceUKMale.getString(context),
          "en-IN-Neural2-A": AppLocale.settingsPageVoiceINFemale.getString(context),
          "en-IN-Neural2-B": AppLocale.settingsPageVoiceINMale.getString(context),
          "en-AU-Neural2-C": AppLocale.settingsPageVoiceAUFemale.getString(context),
          "en-AU-Neural2-B": AppLocale.settingsPageVoiceAUMale.getString(context),
        };

      case 'vi':
        voiceTypes = [
          "vi-VN-Standard-A",
          "vi-VN-Standard-B",
        ];
        voiceTypeTitles = {
          "vi-VN-Standard-A": AppLocale.settingsPageVoiceVIFemale.getString(context),
          "vi-VN-Standard-B": AppLocale.settingsPageVoiceVIMale.getString(context),
        };
    }
  }


  void _handleTap(String value) {
    setState(() {
      _selectedVoicePreference = value;
      widget.updatePreferenceCallback('voicePreference', value);
      if (_selectedVoicePreference != null) {
        _googleTTSUtil.speak(AppLocale.generalAccentPreview.getString(context),
            _selectedVoicePreference!);
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
    const units = ["B", "KiB", "MiB", "GiB"];

    // Convert size to largest unit
    double size = (await getCacheSize()).toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
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
            "${AppLocale.settingsPageClearCache.getString(context)} ($_sizeText)",
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

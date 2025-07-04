import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/stats/exercise_score_model.dart';
import 'package:hearbat/stats/module_model.dart';
import 'package:hearbat/utils/background_noise_util.dart';
import 'package:hearbat/utils/google_stt_util.dart';
import 'package:hearbat/utils/google_tts_util.dart';
import 'package:hearbat/utils/translations.dart';
import 'package:hearbat/widgets/module/score_widget.dart';
import 'package:hearbat/widgets/module/module_progress_bar_widget.dart';
import 'package:hearbat/widgets/module/check_button_widget.dart';
import 'package:hearbat/streaks/streaks_provider.dart';

class SpeechModuleWidget extends StatefulWidget {
 final String title;
 final List<String> sentences;
 final String voiceType;

 SpeechModuleWidget(
     {required this.title, required this.sentences, required this.voiceType});

 @override
 SpeechModuleWidgetState createState() => SpeechModuleWidgetState();
}

class SpeechModuleWidgetState extends State<SpeechModuleWidget> {
 late FlutterSoundRecorder _recorder;
 bool _isRecording = false;
 bool _recorderInitialized = false; // Add this flag
 String _transcription = '';
 String _sentence = '';
 double _grade = 0.0;
 double _gradeSum = 0.0;
 int _highScore = 0;
 int _attempts = 0;
 String voiceType = '';
 bool _isSubmitted = false;
 bool _isCompleted = false;
 int currentSentenceIndex = 0;
 int numberOfExercises = 8;
 String language = 'English';
 bool _isCheckPressed = false;
 DateTime? _moduleStartTime;
 late StreakProvider _streakProvider;
 ConfettiController _confettiController =
     ConfettiController(duration: const Duration(seconds: 3));

 final GoogleTTSUtil _ttsUtil = GoogleTTSUtil();

 String? selectedFeedback = 'on';

 void fetchHighScore() async {
   final module = await Module.getModuleByName(widget.title);
   if (module == null) {
     return;
   }

   _highScore = module.highScore ?? 0;
 }

 @override
 void didChangeDependencies() {
   super.didChangeDependencies();
   _streakProvider = Provider.of<StreakProvider>(context, listen: false);
 }

 @override
 void initState() {
   super.initState();
   _moduleStartTime = DateTime.now();
   voiceType = widget.voiceType;
   _init();
   voiceType = widget.voiceType;
   _loadVoiceType();
   _sentence = _getRandomSentence();
   _playSentence();
   _confettiController.play();
   setState(() {});
   BackgroundNoiseUtil.playSavedSound();
   _loadFeedbackPreference();
   fetchHighScore();
 }

 // Load the saved feedback preference from SharedPreferences
 void _loadFeedbackPreference() async {
   final SharedPreferences prefs = await SharedPreferences.getInstance();
   setState(() {
     selectedFeedback = prefs
         .getString('feedbackPreference'); // Default to 'on' if no saved value
   });
 }

 // Plays the audio that indicates the user selected the correct answer
 void playCorrectChime() async {
   final player = AudioPlayer();
   await player
       .play(AssetSource("audio/sounds/feedback/correct answer chime.mp3"));
 }

 Future<void> _init() async {
   _recorder = FlutterSoundRecorder();
   
   // Request permission first
   final status = await Permission.microphone.request();
   print("Microphone permission status: $status");
   
   if (status.isGranted) {
     try {
       await _recorder.openRecorder();
       setState(() {
         _recorderInitialized = true;
       });
       print("Recorder opened successfully");
     } catch (e) {
       print("Error opening recorder: $e");
       _showErrorDialog("Failed to initialize audio recorder. Please try again.");
     }
   } else if (status.isDenied) {
     _showPermissionDeniedDialog();
   } else if (status.isPermanentlyDenied) {
     _showPermissionPermanentlyDeniedDialog();
   }
 }

 void _showPermissionDeniedDialog() {
   showDialog(
     context: context,
     barrierDismissible: false,
     builder: (context) => AlertDialog(
       title: Text('Microphone Permission Required'),
       content: Text('This app needs microphone access to record your speech for pronunciation practice.'),
       actions: [
         TextButton(
           onPressed: () {
             Navigator.of(context).pop();
             Navigator.of(context).pop(); // Go back to previous screen
           },
           child: Text('Cancel'),
         ),
         TextButton(
           onPressed: () async {
             Navigator.of(context).pop();
             // Try requesting permission again
             final newStatus = await Permission.microphone.request();
             if (newStatus.isGranted) {
               _init(); // Retry initialization
             } else {
               _showPermissionDeniedDialog(); // Show dialog again
             }
           },
           child: Text('Try Again'),
         ),
       ],
     ),
   );
 }

 void _showPermissionPermanentlyDeniedDialog() {
   showDialog(
     context: context,
     barrierDismissible: false,
     builder: (context) => AlertDialog(
       title: Text('Microphone Permission Required'),
       content: Text('Microphone access has been permanently denied. Please enable it in your device settings to use this feature.'),
       actions: [
         TextButton(
           onPressed: () {
             Navigator.of(context).pop();
             Navigator.of(context).pop(); // Go back to previous screen
           },
           child: Text('Cancel'),
         ),
         TextButton(
           onPressed: () {
             Navigator.of(context).pop();
             openAppSettings(); // Opens app settings
           },
           child: Text('Open Settings'),
         ),
       ],
     ),
   );
 }

 void _showErrorDialog(String message) {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: Text('Error'),
       content: Text(message),
       actions: [
         TextButton(
           onPressed: () {
             Navigator.of(context).pop();
             Navigator.of(context).pop(); // Go back to previous screen
           },
           child: Text('OK'),
         ),
       ],
     ),
   );
 }

 Future<void> _loadVoiceType() async {
   final SharedPreferences prefs = await SharedPreferences.getInstance();
   setState(() {
     voiceType = prefs.getString('voicePreference') ?? voiceType;
     language = prefs.getString('languagePreference')!;
   });
 }

 Future<void> _recordModuleCompletion() async {
   if (_moduleStartTime != null) {
     final duration = DateTime.now().difference(_moduleStartTime!).inSeconds;
     await _streakProvider.recordPracticeTimeForDate(duration, _moduleStartTime!);
   }
 }

 Future<void> _playSentence() async {
   await _ttsUtil.speak(_sentence, voiceType, hardModeEnabled: false);
 }

 List<String> shuffledSentences = [];

 String _getRandomSentence() {
   // If shuffledSentences is empty, copy all sentences and shuffle them
   if (shuffledSentences.isEmpty) {
     shuffledSentences = List<String>.from(widget.sentences);
     shuffledSentences.shuffle();
   }

   // Take the last sentence from shuffledSentences
   String sentence = shuffledSentences.removeLast();

   return sentence;
 }

 double _calculateGrade(String original, String transcription) {
   original = original.replaceAll(RegExp(r'\W'), '').toLowerCase();
   transcription = transcription.replaceAll(RegExp(r'\W'), '').toLowerCase();

   int distance = _levenshteinDistance(original, transcription);
   int maxLength = max(original.length, transcription.length);

   return (1 - distance / maxLength) * 100;
 }

 int _levenshteinDistance(String s, String t) {
   if (s == t) return 0;
   if (s.isEmpty) return t.length;
   if (t.isEmpty) return s.length;

   List<int> v0 = List.filled(t.length + 1, 0);
   List<int> v1 = List.filled(t.length + 1, 0);

   for (int i = 0; i < t.length + 1; i++) {
     v0[i] = i;
   }

   for (int i = 0; i < s.length; i++) {
     v1[0] = i + 1;

     for (int j = 0; j < t.length; j++) {
       int cost = (s[i] == t[j]) ? 0 : 1;
       v1[j + 1] = min(min(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);
     }

     for (int j = 0; j < t.length + 1; j++) {
       v0[j] = v1[j];
     }
   }

   return v1[t.length];
 }

 Future<void> _toggleRecording() async {
   // Check if recorder is properly initialized
   if (!_recorderInitialized) {
     _showErrorDialog("Microphone is not available. Please check permissions.");
     return;
   }

   final dir = await getApplicationDocumentsDirectory();
   final path = '${dir.path}/flutter_sound_example.wav';
   
   try {
     if (_isRecording) {
       await _recorder.stopRecorder();
       final sttUtil = GoogleSTTUtil();
       try {
         final transcription = await sttUtil.transcribeAudio(path, language);
         double grade = _calculateGrade(_sentence, transcription);
         setState(() {
           _transcription = transcription;
           _grade = grade;
           _isSubmitted = true;
         });
       } catch (e) {
         setState(() {
           _transcription = AppLocale.speechModuleWidgetFailedTranscription
               .getString(context);
           _grade = 0.0;
           _isSubmitted = true;
         });
       }
     } else {
       await _recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);
     }
     setState(() {
       _isRecording = !_isRecording;
     });
   } catch (e) {
     print("Recording error: $e");
     _showErrorDialog("Recording failed. Please try again.");
   }
 }

 int _getEffectiveScore() {
   return (_gradeSum / _attempts).ceil();
 }

 void _submitRecording() async {
   setState(() {
     _gradeSum += _grade; // This is being called twice...
     _attempts++;
     _isCheckPressed = !_isCheckPressed;
     if (_isCheckPressed == false) {
       currentSentenceIndex++;
       if (currentSentenceIndex < numberOfExercises) {
         _sentence = _getRandomSentence();
         _playSentence();
       } else {
         _isCompleted = true;
       }
       _isSubmitted = false;
       _transcription = '';
     }
     if (_grade == 100 && _isCheckPressed) {
       if (selectedFeedback == 'On') {
         playCorrectChime(); // Play a chime if the answer is correct
       }
     }
   });

   // Make sure this is being executed when _isCompleted is true
   if (_isCompleted) {
     const maxScore = 100;
     final score = _getEffectiveScore(); // Average out of 100
     await Module.updateStats("speech", widget.title, score);
     await ExerciseScore.insert("speech", widget.title, DateTime.now(), score, maxScore,
         bgNoise:
             BackgroundNoiseUtil.isPlaying ? BackgroundNoiseUtil.volume : 0.0);
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: _isCompleted
         ? null
         : AppBar(
             surfaceTintColor: Colors.transparent,
             leading: Padding(
               padding: const EdgeInsets.only(left: 18.0),
               child: IconButton(
                 onPressed: () {
                   Navigator.of(context).pop();
                 },
                 icon: Icon(Icons.close, size: 40),
               ),
             ),
             titleSpacing: 0,
             title: ModuleProgressBarWidget(
               currentIndex: currentSentenceIndex,
               total: numberOfExercises,
             ),
             backgroundColor: Color.fromARGB(255, 232, 218, 255),
           ),
     body: SafeArea(
       child: _isCompleted ? buildCompletionScreen() : buildModuleContent(),
     ),
   );
 }

 Widget buildModuleContent() {
   return LayoutBuilder(
     builder: (BuildContext context, BoxConstraints viewportConstraints) {
       return SingleChildScrollView(
         child: ConstrainedBox(
           constraints: BoxConstraints(
             minHeight: viewportConstraints.maxHeight,
           ),
           child: Stack(
             children: [
               Center(
                 child: Padding(
                   padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       Text(
                           AppLocale.speechModuleWidgetPrompt
                               .getString(context),
                           style: TextStyle(
                               fontSize: 24, fontWeight: FontWeight.bold)),
                       SizedBox(height: 20),
                       ElevatedButton.icon(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Color.fromARGB(255, 7, 45, 78),
                           shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(8)),
                           minimumSize: Size(355, 90),
                         ),
                         onPressed: _playSentence,
                         icon: Icon(Icons.volume_up,
                             color: Colors.white, size: 30),
                         label: Text(
                             AppLocale.speechModuleWidgetPlayAudio
                                 .getString(context),
                             style:
                                 TextStyle(fontSize: 20, color: Colors.white)),
                       ),
                       SizedBox(height: 30),
                       ElevatedButton(
                         onPressed: (_isCheckPressed || !_recorderInitialized) ? null : _toggleRecording,
                         style: ElevatedButton.styleFrom(
                           foregroundColor: Colors.white,
                           backgroundColor:
                               _isRecording ? Colors.red : Colors.green,
                           disabledBackgroundColor: Colors.grey,
                           padding: EdgeInsets.symmetric(
                               horizontal: 50, vertical: 20),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                         ),
                         child: Text(
                             !_recorderInitialized 
                                 ? "Microphone Not Available"
                                 : _isRecording
                                     ? AppLocale.speechModuleWidgetStopRecording
                                         .getString(context)
                                     : AppLocale.speechModuleWidgetStartRecording
                                         .getString(context),
                             style:
                                 TextStyle(fontSize: 20, color: Colors.white)),
                       ),
                       SizedBox(height: 30),
                       if (_transcription.isNotEmpty)
                         Container(
                           padding: EdgeInsets.all(30),
                           decoration: BoxDecoration(
                             color: Colors.blue[100],
                             borderRadius: BorderRadius.circular(10),
                           ),
                           child: Text(
                               '${AppLocale.speechModuleWidgetWhatYouSaid.getString(context)} $_transcription',
                               style: TextStyle(
                                   fontSize: 18, color: Colors.black),
                               textAlign: TextAlign.center),
                         ),
                       SizedBox(height: 30),
                       if (_isSubmitted && _isCheckPressed) ...[
                         Container(
                           padding: EdgeInsets.all(30),
                           decoration: BoxDecoration(
                             color: Colors.green[100],
                             borderRadius: BorderRadius.circular(10),
                           ),
                           child: Text(
                               '${AppLocale.speechModuleWidgetOriginal.getString(context)} $_sentence',
                               style: TextStyle(
                                   fontSize: 18, color: Colors.black),
                               textAlign: TextAlign.center),
                         ),
                         SizedBox(height: 30),
                         Text(
                             '${AppLocale.speechModuleWidgetAccuracy.getString(context)} ${_grade.toStringAsFixed(2)}%',
                             style: TextStyle(
                                 fontSize: 20, fontWeight: FontWeight.bold),
                             textAlign: TextAlign.center),
                       ],
                     ],
                   ),
                 ),
               ),
               Positioned(
                 bottom: 0,
                 left: 0,
                 right: 0,
                 child: Padding(
                   padding:
                       const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                   child: SizedBox(
                     width: 350,
                     height: 56,
                     child: CheckButtonWidget(
                       isCheckingAnswer: !_isCheckPressed,
                       isSelectedWordValid:
                           !_isRecording && _transcription.isNotEmpty,
                       onPressed: _submitRecording,
                       language: language,
                     ),
                   ),
                 ),
               ),
             ],
           ),
         ),
       );
     },
   );
 }

 Widget buildCompletionScreen() {
   WidgetsBinding.instance.addPostFrameCallback((_) {
     _recordModuleCompletion();
   });
   return Stack(
     alignment: Alignment.topCenter,
     children: [
       ConfettiWidget(
         confettiController: _confettiController,
         blastDirectionality: BlastDirectionality.explosive,
         particleDrag: 0.05,
         emissionFrequency: 0.1,
         numberOfParticles: 8,
         gravity: 0.2,
         colors: const [
           Colors.yellow,
           Colors.blue,
           Colors.pink,
           Colors.orange,
           Colors.green
         ],
       ),
       Column(mainAxisAlignment: MainAxisAlignment.center, children: [
         Padding(
           padding:
               const EdgeInsets.only(left: 120.0, right: 120.0, top: 60.0),
           child: Image.asset("assets/visuals/HBCompletion.png",
               fit: BoxFit.contain),
         ),
         Padding(
           padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
           child: AutoSizeText(
             AppLocale.generalLessonComplete.getString(context),
             maxLines: 1,
             style: TextStyle(
                 fontSize: 32,
                 fontWeight: FontWeight.bold,
                 color: Color.fromARGB(255, 7, 45, 78)),
             textAlign: TextAlign.center,
           ),
         ),
         // Today's score
         ScoreWidget(
           context: context,
           type: ScoreType.average,
           correctAnswersCount: _getEffectiveScore().toStringAsFixed(2),
           subtitleText:
               AppLocale.speechModuleWidgetAverage.getString(context),
           isHighest: _getEffectiveScore() > _highScore,
           icon: Icon(
             Icons.star,
             color: Color.fromARGB(255, 7, 45, 78),
             size: 30,
           ),
           boxDecoration: gradientBoxDecoration,
           total: 100, // editing
         ),
         ScoreWidget(
           context: context,
           type: ScoreType.average,
           correctAnswersCount: _getEffectiveScore() > _highScore
               ? _getEffectiveScore().toStringAsFixed(2)
               : _highScore.toStringAsFixed(2),
           subtitleText: AppLocale.speechModuleWidgetHighestAverage.getString(context),
           isHighest: true,
           icon: Icon(
             Icons.emoji_events,
             color: Color.fromARGB(255, 255, 255, 255),
             size: 30,
           ),
           boxDecoration: blueBoxDecoration,
           total: 100, // editing
         ),
         Padding(
           padding: const EdgeInsets.only(
               top: 40.0, bottom: 40.0, left: 20, right: 20),
           child: ElevatedButton(
             onPressed: () {
               Navigator.pop(context);
               if (Navigator.canPop(context)) {
                 Navigator.pop(context);
               }
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Color.fromARGB(255, 94, 224, 82),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
               minimumSize: Size(400, 50),
               elevation: 5,
             ),
             child: Text(
               AppLocale.generalContinue.getString(context),
               style: TextStyle(
                 color: const Color.fromARGB(255, 255, 255, 255),
                 fontSize: 20,
                 fontWeight: FontWeight.w600,
               ),
             ),
           ),
         ),
       ])
     ],
   );
 }

 @override
 void dispose() {
   if (!_isCompleted) {
     _recordModuleCompletion(); // ← Catches all other exits
   }
   if (_recorderInitialized) {
     _recorder.closeRecorder();
   }
   _confettiController.dispose();
   BackgroundNoiseUtil.stopSound();
   super.dispose();
 }
}
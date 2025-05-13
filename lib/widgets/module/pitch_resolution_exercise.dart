import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/background_noise_util.dart';
import 'package:hearbat/widgets/module/module_progress_bar_widget.dart';
import 'package:hearbat/widgets/module/score_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearbat/utils/audio_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/streaks/streaks_provider.dart';

class MissedAnswer {
  final int semitoneDifference;
  final String correctDirection;
  final String incorrectDirection;
  final String audioPath;

  MissedAnswer({
    required this.semitoneDifference,
    required this.correctDirection,
    required this.incorrectDirection,
    required this.audioPath,
  });
}

class PitchResolutionExercise extends StatefulWidget {
  final List<AnswerGroup> answerGroups;

  PitchResolutionExercise({required this.answerGroups});

  @override
  PitchResolutionExerciseState createState() => PitchResolutionExerciseState();
}

class PitchResolutionExerciseState extends State<PitchResolutionExercise> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  List<MissedAnswer> missedAnswers = [];
  bool isPlaying = false;
  bool showFeedback = false;
  bool isCorrect = false;
  bool moduleCompleted = false;
  String selectedFeedback = 'On';
  String? _selectedDirection;
  Answer? currentCorrectAnswer;
  ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _loadFeedbackPreference();
    _initializeQuestion();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    AudioUtil.initialize();
    BackgroundNoiseUtil.initialize().then((_) {
      BackgroundNoiseUtil.playSavedSound();
    });
  }

  @override
  void dispose() {
    BackgroundNoiseUtil.stopSound();
    AudioUtil.stop();
    _confettiController.dispose();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('difficultyPreference', 'Normal');
      prefs.setString('backgroundSoundPreference', 'None');
      prefs.setString('audioVolumePreference', 'Low');
    });

    super.dispose();
  }

  void _loadFeedbackPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFeedback = prefs.getString('feedbackPreference') ?? 'On';
    });
  }

  //Used to record activity for streaks
  Future<void> _recordStreakActivity() async {
    try {
      final provider = Provider.of<StreakProvider>(context, listen: false);
      await provider.recordActivity(1); // This handles both DB update and UI refresh
    } catch (e) {
      print('Error recording streak activity: $e');
    }
  }

  void playCorrectChime() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/sounds/feedback/correct answer chime.mp3"));
  }

  // Plays the audio that indicates the user selected the wrong answer
  void playWrongChime() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/sounds/feedback/wrong answer chime.mp3"));
  }

  void _initializeQuestion() {
    final currentGroup = widget.answerGroups[currentQuestionIndex];
    final random = Random();
    currentCorrectAnswer = currentGroup.answers[random.nextInt(2)];
    _playCurrentQuestionAudio();
  }

  void _playCurrentQuestionAudio() async {
    if (currentCorrectAnswer == null) return;
    print("Playing audio file: ${currentCorrectAnswer!.path}");
    await AudioUtil.playSound(currentCorrectAnswer!.path!);
  }

  // Extract semitone difference from the audio file path
  int extractSemitoneDifference(String path) {
    final regex = RegExp(r'[ud](\d+)\.mp3$'); // Matches "u7.mp3" or "d12.mp3"
    final match = regex.firstMatch(path);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  void checkAnswer(String selectedAnswer) {
    if (currentCorrectAnswer == null || _selectedDirection != null) return;

    _recordStreakActivity(); // Record streak activity when a question is answered

    final semitoneDifference = extractSemitoneDifference(currentCorrectAnswer!.path!);
    final isAnswerCorrect = selectedAnswer == currentCorrectAnswer!.answer;

    setState(() {
      _selectedDirection = selectedAnswer;
      showFeedback = true;
      isCorrect = isAnswerCorrect;
    });

    if (isAnswerCorrect) {
      correctAnswers++;
      if (selectedFeedback == 'On') {
        playCorrectChime();
      }
      Future.delayed(Duration(milliseconds: 1000), () {
        if (mounted) {
          moveToNextQuestion();
        }
      });
    } else {
      missedAnswers.add(MissedAnswer(
        semitoneDifference: semitoneDifference,
        correctDirection: currentCorrectAnswer!.answer,
        incorrectDirection: selectedAnswer,
        audioPath: currentCorrectAnswer!.path!,
      ));
      if (selectedFeedback == 'On') {
        playWrongChime();
      }
    }
  }

  void moveToNextQuestion() {
    setState(() {
      _selectedDirection = null;
      showFeedback = false;
      isCorrect = false;
    });

    if (currentQuestionIndex < widget.answerGroups.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _initializeQuestion();
    } else {
      showResults();
    }
  }

  void showResults() {
    setState(() {
      moduleCompleted = true;
    });
  }

  Widget buildCompletionScreen() {
    BackgroundNoiseUtil.stopSound();
    return Scaffold(
      body: Stack(
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 120.0, right: 120.0, top: 60.0),
                        child: Image.asset("assets/visuals/HBCompletion.png", fit: BoxFit.contain),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                        child: AutoSizeText(
                          'Lesson Complete!',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 7, 45, 78)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ScoreWidget(
                        context: context,
                        type: ScoreType.score,
                        correctAnswersCount: correctAnswers.toString(),
                        subtitleText: "Score",
                        icon: Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 7, 45, 78),
                          size: 30,
                        ),
                        boxDecoration: gradientBoxDecoration,
                        total: widget.answerGroups.length,
                      ),
                      ScoreWidget(
                        context: context,
                        type: ScoreType.score,
                        correctAnswersCount: correctAnswers.toString(),
                        subtitleText: "Highest Score",
                        icon: Icon(
                          Icons.emoji_events,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 30,
                        ),
                        boxDecoration: blueBoxDecoration,
                        total: widget.answerGroups.length,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color.fromARGB(255, 7, 45, 78),
                            width: 9.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 7, 45, 78),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Sounds Missed',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            if (missedAnswers.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No sounds missed! Great job!',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 7, 45, 78),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            if (missedAnswers.isNotEmpty)
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: missedAnswers.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final missedAnswer = missedAnswers[index];
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color.fromARGB(255, 7, 45, 78),
                                          width: 6.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'You Chose',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 7, 45, 78),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(255, 0, 0, 0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Image.asset(
                                                    missedAnswer.correctDirection == "Up"
                                                        ? "assets/visuals/music_pitch/down_arrow.png"
                                                        : "assets/visuals/music_pitch/up_arrow.png",
                                                    width: 40,
                                                    height: 40,
                                                  ),
                                                ),
                                                Text(
                                                  "${missedAnswer.semitoneDifference} Semitones",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 7, 45, 78),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.volume_up,
                                                color: Color.fromARGB(255, 7, 45, 78),
                                                size: 40,
                                              ),
                                              onPressed: () async {
                                                print("Playing missed answer audio: ${missedAnswer.audioPath}");
                                                await AudioUtil.playSound(missedAnswer.audioPath);
                                              },
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Correct',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 7, 45, 78),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(0, 255, 0, 0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Image.asset(
                                                    missedAnswer.correctDirection == "Up"
                                                        ? "assets/visuals/music_pitch/up_arrow.png"
                                                        : "assets/visuals/music_pitch/down_arrow.png",
                                                    width: 40,
                                                    height: 40,
                                                  ),
                                                ),
                                                Text(
                                                  "${missedAnswer.semitoneDifference} Semitones",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 7, 45, 78),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 40.0, left: 20, right: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
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
                    'CONTINUE',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExerciseContent() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
                child: Text(
                  'Is the second note higher or lower?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 45, 78),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 7, 45, 78),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(355, 90),
                  ),
                  onPressed: _playCurrentQuestionAudio,
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 50,
                  ),
                  label: Text(''),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Up Button
                    Container(
                      margin: EdgeInsets.only(right: 27.5),
                      child: GestureDetector(
                        onTap: _selectedDirection == null ? () => checkAnswer("Up") : null,
                        child: Container(
                          width: 150,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: _selectedDirection == "Up"
                                ? Border.all(
                                color: isCorrect ? Colors.green : Colors.red,
                                width: 4)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: _selectedDirection != null && _selectedDirection != "Up" ? 0.5 : 1.0,
                              child: Image.asset(
                                "assets/visuals/music_pitch/up_arrow.png",
                                width: 100,
                                height: 100,
                                color: _selectedDirection == "Up"
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : null,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text("Up");
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Down Button
                    Container(
                      margin: EdgeInsets.only(left: 27.5),
                      child: GestureDetector(
                        onTap: _selectedDirection == null ? () => checkAnswer("Down") : null,
                        child: Container(
                          width: 150,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: _selectedDirection == "Down"
                                ? Border.all(
                                color: isCorrect ? Colors.green : Colors.red,
                                width: 4)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: _selectedDirection != null && _selectedDirection != "Down" ? 0.5 : 1.0,
                              child: Image.asset(
                                "assets/visuals/music_pitch/down_arrow.png",
                                width: 100,
                                height: 100,
                                color: _selectedDirection == "Down"
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : null,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text("Down");
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showFeedback)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: isCorrect
                ? Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Great',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 7, 45, 78),
                    ),
                  ),
                ),
              ),
            ).animate(onPlay: (controller) => controller.forward()).slide(
                begin: Offset(0, 1),
                duration: 300.ms,
                curve: Curves.easeInOutQuart)
                : Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: Text(
                          'Incorrect',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 7, 45, 78),
                          ),
                        ),
                      ),
                      Text(
                        'Correct',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 7, 45, 78),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Lower",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print("Playing correct answer audio: ${currentCorrectAnswer!.path}");
                            AudioUtil.playSound(currentCorrectAnswer!.path!);
                          },
                          icon: Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 30,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Higher",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 350,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 45, 78),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: moveToNextQuestion,
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: moduleCompleted
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
          currentIndex: currentQuestionIndex,
          total: widget.answerGroups.length,
        ),
        backgroundColor: Color.fromARGB(255, 232, 218, 255),
      ),
      body: SafeArea(
        child: moduleCompleted ? buildCompletionScreen() : buildExerciseContent(),
      ),
    );
  }

  // Reuse the ScoreWidget and box decorations
  var gradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 248, 213, 245),
        Color.fromARGB(255, 255, 192, 199),
        Color.fromARGB(255, 213, 177, 239),
      ],
    ),
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(
      color: Color.fromARGB(255, 7, 45, 78),
      width: 3.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha((0.5 * 255).toInt()),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  );

  var blueBoxDecoration = BoxDecoration(
    color: Color.fromARGB(255, 7, 45, 78),
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(
      color: Color.fromARGB(255, 7, 45, 78),
      width: 3.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha((0.5 * 255).toInt()),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  );
}
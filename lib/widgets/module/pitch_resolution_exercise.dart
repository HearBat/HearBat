import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/background_noise_util.dart';
import 'package:hearbat/widgets/module/module_progress_bar_widget.dart';
import 'package:hearbat/widgets/module/score_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearbat/utils/audio_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';

class MissedAnswer {
  final int semitoneDifference;
  final String correctDirection;
  final String audioPath;

  MissedAnswer({
    required this.semitoneDifference,
    required this.correctDirection,
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
  Answer? currentCorrectAnswer;
  ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _loadFeedbackPreference();
    _initializeQuestion();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _initializeBackgroundNoise();
    AudioUtil.initialize();
  }

  @override
  void dispose() {
    BackgroundNoiseUtil.stopSound();
    AudioUtil.stop();
    _confettiController.dispose();
    super.dispose();
  }

  // Initialize and play background noise
  void _initializeBackgroundNoise() async {
    await BackgroundNoiseUtil.playSavedSound();
  }

  void _loadFeedbackPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFeedback = prefs.getString('feedbackPreference') ?? 'On';
    });
  }

  void playCorrectChime() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/sounds/feedback/correct answer chime.mp3"));
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
    if (currentCorrectAnswer == null) return;

    final semitoneDifference = extractSemitoneDifference(currentCorrectAnswer!.path!);

    setState(() {
      showFeedback = true;
      isCorrect = selectedAnswer == currentCorrectAnswer!.answer;
    });

    if (isCorrect) {
      correctAnswers++;
      if (selectedFeedback == 'On') {
        playCorrectChime();
      }
      // Automatically move to the next question after a short delay
      Future.delayed(Duration(milliseconds: 1000), () {
        moveToNextQuestion();
      });
    } else {
      missedAnswers.add(MissedAnswer(
        semitoneDifference: semitoneDifference,
        correctDirection: currentCorrectAnswer!.answer,
        audioPath: currentCorrectAnswer!.path!,
      ));
    }
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < widget.answerGroups.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showFeedback = false;
      });
      _initializeQuestion();
    } else {
      showResults(); // Show results if all questions are answered
    }
  }

  void showResults() {
    setState(() {
      moduleCompleted = true;
    });
  }

  Widget buildCompletionScreen() {
    BackgroundNoiseUtil.stopSound();
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti Animation
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
        // Completion Screen Content
        Column(
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
            // Score Widget for Correct Answers
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
            // Score Widget for Highest Score
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
            // Sounds Missed Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Text(
                'Sounds Missed',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 45, 78)),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: missedAnswers.length,
                itemBuilder: (BuildContext context, int index) {
                  final missedAnswer = missedAnswers[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Semitone Text
                            Text(
                              "${missedAnswer.semitoneDifference} Semitones",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 7, 45, 78)),
                            ),
                            // Sound Icon to Replay the Missed Tone
                            IconButton(
                              icon: Icon(
                                Icons.volume_up,
                                color: Color.fromARGB(255, 7, 45, 78),
                                size: 30,
                              ),
                              onPressed: () async {
                                // Replay the missed tone using the stored audioPath
                                await AudioUtil.playSound(missedAnswer.audioPath);
                                print("Playing audio file: ${missedAnswer.audioPath}"); // Debug print
                              },
                            ),
                            // Red Arrow (Incorrect Guess)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 0, 0, 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                missedAnswer.correctDirection == "Up"
                                    ? "assets/visuals/music_pitch/down_arrow.png"
                                    : "assets/visuals/music_pitch/up_arrow.png",
                                width: 30,
                                height: 30,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    missedAnswer.correctDirection == "Up"
                                        ? "Down"
                                        : "Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Green Arrow (Correct Answer)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 255, 0, 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                missedAnswer.correctDirection == "Up"
                                    ? "assets/visuals/music_pitch/up_arrow.png"
                                    : "assets/visuals/music_pitch/down_arrow.png",
                                width: 30,
                                height: 30,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    missedAnswer.correctDirection,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 40.0, left: 20, right: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
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
    );
  }

  Widget buildExerciseContent() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 40.0),
                child: Text(
                  'Is the second note higher or lower?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 45, 78),
                  ),
                ),
              ),
              // Sound Icon Button with Blue Background
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 40.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 7, 45, 78),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(355, 90),
                  ),
                  onPressed: () {
                    _playCurrentQuestionAudio();
                  },
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 50,
                  ),
                  label: Text(''),
                ),
              ),
              // Two Rectangular Buttons for Up and Down
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Up Button
                    GestureDetector(
                      onTap: () {
                        checkAnswer("Up");
                      },
                      child: Container(
                        width: 150,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8), // Rounded corners
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
                          child: Image.asset(
                            "assets/visuals/music_pitch/up_arrow.png",
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading image: up_arrow.png"); // Debug print
                              return Text("Up");
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    // Down Button
                    GestureDetector(
                      onTap: () {
                        checkAnswer("Down");
                      },
                      child: Container(
                        width: 150,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
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
                          child: Image.asset(
                            "assets/visuals/music_pitch/down_arrow.png",
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading image: down_arrow.png"); // Debug print
                              return Text("Down");
                            },
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
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: isCorrect ? Colors.green : Colors.red,
              child: Column(
                children: [
                  Text(
                    isCorrect ? "Correct" : "Incorrect",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCorrect)
                    SizedBox(height: 50),
                  if (!isCorrect)
                    Column(
                      children: [
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: moveToNextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 7, 45, 78),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(200, 50),
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          )
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
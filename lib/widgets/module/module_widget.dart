import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/background_noise_util.dart';
import 'package:hearbat/utils/audio_util.dart';
import 'package:hearbat/widgets/module/module_progress_bar_widget.dart';
import 'four_answer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearbat/utils/google_tts_util.dart';
import 'word_missed_button_widget.dart';
import 'package:confetti/confetti.dart';
import 'score_widget.dart';

class ModuleWidget extends StatefulWidget {
  final String title;
  final List<AnswerGroup> answerGroups;
  final bool isWord;

  ModuleWidget(
      {super.key,
      required this.title,
      required this.answerGroups,
      required this.isWord});

  @override
  State createState() => _ModulePageState();
}

class _ModulePageState extends State<ModuleWidget> {
  bool moduleCompleted = false;
  int currentIndex = 0;
  int correctAnswersCount = 0;
  GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();
  List<List<Answer>> incorrectAnswerPairs = [];
  String voiceType = "en-US-Studio-O";
  ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  String language = 'English';

  @override
  void initState() {
    super.initState();
    getVoiceType();
    _confettiController.play();

    googleTTSUtil.initialize();
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

  void getVoiceType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedVoiceType = prefs.getString('voicePreference');
    language = prefs.getString('languagePreference')!;

    if (storedVoiceType != null) {
      setState(() {
        voiceType = storedVoiceType;
      });
    }
  }

  void updateProgress(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });
  }

  void playAnswer(Answer answer) {
    if (widget.isWord) {
      googleTTSUtil.speak(answer.answer, voiceType);
    } else {
      AudioUtil.playSound(answer.path!);
    }
  }

  Widget listIncorrectAnswers() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.fromARGB(255, 7, 45, 78),
              width: 3.0,
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Words Missed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: incorrectAnswerPairs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 7, 45, 78),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnswerButton(
                            answer: incorrectAnswerPairs[index][0].answer,
                            onPressed: () =>
                                playAnswer(incorrectAnswerPairs[index][0]),
                            headerText: 'You Chose',
                            color: Color.fromARGB(255, 195, 74, 74),
                          ),
                          SizedBox(width: 8),
                          AnswerButton(
                              answer: incorrectAnswerPairs[index][1].answer,
                              onPressed: () =>
                                  playAnswer(incorrectAnswerPairs[index][1]),
                              headerText: 'Correct Answer',
                              color: Color.fromARGB(255, 129, 221, 121)),
                        ],
                      ),
                    ),
                  );
                },
              ))
            ],
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
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('difficultyPreference', 'Normal');
                      prefs.setString('backgroundSoundPreference', 'None');
                      prefs.setString('audioVolumePreference', 'Low');
                    });
                    BackgroundNoiseUtil.stopSound();
                    AudioUtil.stop();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close, size: 40),
                ),
              ),
              titleSpacing: 0,
              title: ModuleProgressBarWidget(
                currentIndex: currentIndex,
                total: widget.answerGroups.length,
              ),
              backgroundColor: Color.fromARGB(255, 232, 218, 255),
            ),
      body: Center(
        child: moduleCompleted ? buildCompletionScreen() : buildModuleContent(),
      ),
    );
  }

  Widget buildModuleContent() {
    return Container(
      color: Color.fromARGB(255, 232, 218, 255),
      child: FourAnswerWidget(
        answerGroups: widget.answerGroups,
        onCompletion: () => setState(() => moduleCompleted = true),
        onCorrectAnswer: () {
          setState(() {
            correctAnswersCount++;
          });
        },
        onIncorrectAnswer: (selectedAnswer, correctAnswer) {
          setState(() {
            incorrectAnswerPairs.add([selectedAnswer, correctAnswer]);
          });
        },
        voiceType: voiceType,
        isWord: widget.isWord,
        onProgressUpdate: updateProgress,
      ),
    );
  }

  Widget buildCompletionScreen() {
    BackgroundNoiseUtil.stopSound();
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
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 120.0, right: 120.0, top: 60.0),
              child: Image.asset("assets/visuals/HBCompletion.png",
                  fit: BoxFit.contain),
            ),
            // Spacer(flex: 1),
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
            // Today's score
            ScoreWidget(
              context: context,
              type: ScoreType.score,
              correctAnswersCount: correctAnswersCount.toString(),
              subtitleText: "Score",
              icon: Icon(
                Icons.star,
                color: Color.fromARGB(255, 7, 45, 78),
                size: 30,
              ),
              boxDecoration: gradientBoxDecoration,
              total: widget.answerGroups.length, // editting
            ),
            ScoreWidget(
              context: context,
              type: ScoreType.score,
              correctAnswersCount: correctAnswersCount.toString(),
              subtitleText: "Highest Score",
              icon: Icon(
                Icons.emoji_events,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
              boxDecoration: blueBoxDecoration,
              total: widget.answerGroups.length, // editting
            ),
            Expanded(
              flex: 2,
              child: listIncorrectAnswers(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 40.0, bottom: 40.0, left: 20, right: 20),
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
}

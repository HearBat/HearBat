import "dart:math";
import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import '../../utils/translations.dart';
import 'word_button_widget.dart';
import 'incorrect_card_widget.dart';
import '../../utils/google_tts_util.dart';
import '../../utils/audio_util.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class FourAnswerWidget extends StatefulWidget {
  final List<AnswerGroup> answerGroups;
  final VoidCallback onCompletion;
  final VoidCallback onCorrectAnswer;
  final void Function(Answer, Answer) onIncorrectAnswer;
  final String voiceType;
  final bool isWord;
  final Function(int) onProgressUpdate; //for progress bar in parent

  FourAnswerWidget({
    super.key,
    required this.answerGroups,
    required this.onCompletion,
    required this.onCorrectAnswer,
    required this.onIncorrectAnswer,
    required this.voiceType,
    required this.isWord,
    required this.onProgressUpdate,
  });

  @override
  State<FourAnswerWidget> createState() => _FourAnswerWidgetState();
}

class _FourAnswerWidgetState extends State<FourAnswerWidget> {
  GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();
  late List<AnswerGroup> answerGroups;
  late AnswerGroup currentGroup;
  late Answer correctWord;
  Answer? incorrectWord;
  Answer? selectedWord;
  bool isAnswerFalse = false;
  bool isAnswerTrue = false;
  bool readyForCompletion = false;
  int currentIndex = 0;
  String language = 'English';
  String ?selectedFeedback = 'On';

  @override
  void initState() {
    super.initState();
    _loadPreference();
    answerGroups = List<AnswerGroup>.from(widget.answerGroups);
    setNextPair();
    _loadFeedbackPreference();
  }

  // Load the saved feedback preference from SharedPreferences
  void _loadFeedbackPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFeedback = prefs.getString('feedbackPreference'); // Default to 'on' if no saved value
    });
  }

  // Plays the audio that indicates the user selected the correct answer
  void playCorrectChime() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/sounds/feedback/correct answer chime.mp3"));
  }

  // Plays the audio that indicates the user selected the wrong answer
  void playWrongChime() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/sounds/feedback/wrong answer chime.mp3"));
  }

  // Loads the language preference from SharedPreferences.
  Future<void> _loadPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getString('languagePreference') ?? 'English';
  }

  // Sets the next pair of answers and initializes the state.
  void setNextPair() {
    if (answerGroups.isNotEmpty) {
      int index = Random().nextInt(answerGroups.length);
      currentGroup = answerGroups[index];
      answerGroups
          .removeAt(index); // So the randomly chosen pair doesn't repeat

      correctWord = currentGroup.getRandomAnswer(currentGroup);
      selectedWord = null;
      isAnswerFalse = false;
      isAnswerTrue = false;
      readyForCompletion = false;
    } else {
      // If no more answer groups, trigger completion
      Future.delayed(Duration(milliseconds: 500), () {
        widget.onCompletion();
      });
    }

    // Play the question audio after a delay.
    Future.delayed(Duration(milliseconds: 300), () {
      playAnswer(isQuestion: true); // Play the question
    });
  }

  // Handles the selection of an answer by the user and automatically checks it.
  void handleSelection(Answer word) {
    setState(() {
      selectedWord = word;
    });

    // Automatically check the answer after selection
    checkAnswer();
  }

  // Checks if the selected answer is correct and updates the state.
  void checkAnswer() {
    setState(() {
      if (selectedWord!.answer == correctWord.answer) {
        if (selectedFeedback == 'On') {
          playCorrectChime(); // Play a chime if the answer is correct
        }
        print("Correct");
        widget.onCorrectAnswer();
        isAnswerTrue = true;

        // For correct answers, automatically move to next question after a short delay
        Future.delayed(Duration(milliseconds: 1000), () {
          if (answerGroups.isEmpty) {
            widget.onCompletion();
          } else {
            setNextPair();
            setState(() {});
          }
        });
      } else {
        if (selectedFeedback == 'On') {
          playWrongChime(); // Play a chime if the answer is wrong
        }
        print("Incorrect");
        widget.onIncorrectAnswer(selectedWord!, correctWord);
        incorrectWord = selectedWord;
        isAnswerFalse = true;
        // For incorrect answers, we'll let the user proceed manually with the continue button
      }

      if (answerGroups.isEmpty) readyForCompletion = true;
      ++currentIndex;
      indexChange();
    });
  }

  // Proceed to next question or complete the exercise
  void proceedToNext() {
    if (readyForCompletion) {
      widget.onCompletion();
    } else {
      setNextPair();
      setState(() {});
    }
  }

  // Plays the audio for the correct answer
  void playAnswer({bool isQuestion = false}) {
    if (widget.isWord) {
      googleTTSUtil.speak(correctWord.answer, widget.voiceType,
          isQuestion: isQuestion);
    } else {
      AudioUtil.playSound(correctWord.path!);
    }
  }



  // Updates the progress bar in the parent widget.
  void indexChange() {
    widget.onProgressUpdate(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Play button and question text
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocale.fourAnswerWidgetPrompt.getString(context),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Color.fromARGB(255, 7, 45, 78)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 7, 45, 78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(355, 90),
                    ),
                    onPressed: () =>
                        playAnswer(isQuestion: true), // Play the question
                    icon: Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 50,
                    ),
                    label: Text(''),
                  ),
                ),
                // Space between play button and 4 cards
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: !widget.isWord
                      ? GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20, // horizontal spacing
                            mainAxisSpacing: 15, // vertical spacing
                            childAspectRatio: 150 / 180,
                          ),
                          itemCount: 4,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            Answer word = currentGroup.answers[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: WordButton(
                                word: word,
                                isWord: widget.isWord,
                                selectedWord: selectedWord,
                                onSelected: handleSelection,
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            Answer word = currentGroup.answers[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: WordButton(
                                word: word,
                                isWord: widget.isWord,
                                selectedWord: selectedWord,
                                onSelected: handleSelection,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (isAnswerFalse) ...[
              ModalBarrier(dismissible: false),
              Container(
                width: double.infinity,
                height: 220,
                color: Color.fromARGB(255, 255, 255, 255),
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: IncorrectCardWidget(
                        incorrectWord: incorrectWord!,
                        correctWord: correctWord,
                        voiceType: widget.voiceType,
                        isWord: widget.isWord,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Text(
                              AppLocale.generalIncorrect.getString(context),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 7, 45, 78),
                              ),
                            ),
                          ),
                          Text(
                            AppLocale.generalCorrect.getString(context),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 7, 45, 78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Continue button for incorrect answers
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
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
                            onPressed: proceedToNext,
                            child: Text(
                              AppLocale.generalContinue.getString(context),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.forward()).slide(
                  begin: Offset(0, 1),
                  duration: 300.ms,
                  curve: Curves.easeInOutQuart),
            ],
            if (isAnswerTrue) ...[
              ModalBarrier(dismissible: false),
              Container(
                width: double.infinity,
                height: 100,
                color: Color.fromARGB(255, 255, 255, 255),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      AppLocale.generalGreat.getString(context),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.forward()).slide(
                  begin: Offset(0, 1),
                  duration: 300.ms,
                  curve: Curves.easeInOutQuart),
            ],
          ],
        ),
      ],
    );
  }
}

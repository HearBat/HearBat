import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'module_types/words/word_chapters.dart';
import 'module_types/sound/sound_chapters.dart';
import 'module_types/speech/speech_chapters.dart';
import 'module_types/custom/custom_path.dart';
import 'module_types/music/music_chapters.dart';
import '../widgets/home_card_widget.dart';
import '../utils/text_util.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 30),
                        Text(
                          "HearBat",
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 100,
                              color: Color.fromARGB(255, 7, 45, 78),
                              height: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          "your hearing companion",
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 30,
                              color: Color.fromARGB(255, 7, 45, 78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              HomeCardWidget(
                cardText: 'Train Words',
                description: wordDesc,
                destinationPage: WordChapters(),
                image: "assets/visuals/HB_Word.png",
              ),
              HomeCardWidget(
                cardText: 'Train Sounds',
                description: soundDesc,
                destinationPage: SoundChapters(),
                image: "assets/visuals/HB_Music.png",
              ),
              HomeCardWidget(
                cardText: 'Train Speech',
                description: speechDesc,
                destinationPage: SpeechChapters(),
                image: "assets/visuals/HB_Speech.png",
              ),
              HomeCardWidget(
                cardText: 'Train Music',
                description: musicDesc,
                destinationPage: MusicChapters(),
                image: "assets/visuals/HB_Music.png",
              ),
              HomeCardWidget(
                cardText: 'Custom Module Builder',
                description: customDesc,
                destinationPage: CustomPath(),
                image: "assets/visuals/HB_Custom.png",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

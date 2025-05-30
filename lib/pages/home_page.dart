import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'module_types/words/word_chapters.dart';
import 'module_types/sound/sound_chapters.dart';
import 'module_types/speech/speech_chapters.dart';
import 'module_types/custom/custom_path.dart';
import 'module_types/music/music_chapters.dart';
import '../widgets/home_card_widget.dart';
import '../utils/translations.dart';

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
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 30),
                          Text(
                            AppLocale.homePageTitle.getString(context),
                            style: GoogleFonts.londrinaSolid(
                              textStyle: TextStyle(
                                fontSize: 100,
                                color: Color.fromARGB(255, 7, 45, 78),
                                height: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            AppLocale.homePageSubtitle.getString(context),
                            style: GoogleFonts.londrinaSolid(
                              textStyle: TextStyle(
                                fontSize: 30,
                                color: Color.fromARGB(255, 7, 45, 78),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              HomeCardWidget(
                cardText: AppLocale.homePageWordsTitle.getString(context),
                description: AppLocale.homePageWordsDesc.getString(context),
                destinationPage: WordChapters(),
                image: "assets/visuals/HB_Word.png",
              ),
              HomeCardWidget(
                cardText: AppLocale.homePageSoundsTitle.getString(context),
                description: AppLocale.homePageSoundsDesc.getString(context),
                destinationPage: SoundChapters(),
                image: "assets/visuals/HB_Music.png",
              ),
              HomeCardWidget(
                cardText: AppLocale.homePageSpeechTitle.getString(context),
                description: AppLocale.homePageSpeechDesc.getString(context),
                destinationPage: SpeechChapters(),
                image: "assets/visuals/HB_Speech.png",
              ),
              HomeCardWidget(
                cardText: AppLocale.homePageMusicTitle.getString(context),
                description: AppLocale.homePageMusicDesc.getString(context),
                destinationPage: MusicChapters(),
                image: "assets/visuals/HB_Music.png",
              ),
              HomeCardWidget(
                cardText: AppLocale.homePageCustomTitle.getString(context),
                description: AppLocale.homePageCustomDesc.getString(context),
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

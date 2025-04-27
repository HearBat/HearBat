import 'package:flutter/material.dart';
import 'package:hearbat/widgets/path/difficulty_selection_widget.dart';
import '../../models/speech_chapter_model.dart';
import 'sound_alternating_path_layout_widget.dart';
import 'animated_button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechModuleListWidget extends StatelessWidget {
  final Map<String, SpeechModule> modules;
  SpeechModuleListWidget({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    var moduleList = modules.entries.toList();

    void navigate(String moduleName, List<String> sentences) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => DifficultySelectionWidget(
            moduleName: moduleName,
            answerGroups: [],
            isWord: false,
            displayDifficulty: false,
            displayVoice: true,
            sentences: sentences,
          ),
          fullscreenDialog: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SoundAlternatingPathLayout(
          itemCount: moduleList.length,
          itemBuilder: (context, index) {
            final module = moduleList[index];
            return Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50 * 1.2,
                    width: 100 * 1.5,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 7, 45, 78),
                      borderRadius: BorderRadius.all(
                          Radius.elliptical(100 * 1.5, 50 * 1.5)),
                    ),
                  ),
                ),
                AnimatedButton(
                  moduleName: module.key,
                  answerGroups: module.value.speechGroups,
                  onButtonPressed: (String key, List<dynamic> value) {
                    navigate(module.key, module.value.speechGroups);
                  },
                ),
              ],
            );
          },
          itemSize: 120.0,
          spacing: 80.0,
        ),
      ),
    );
  }
}

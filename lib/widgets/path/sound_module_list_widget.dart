import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/widgets/path/animated_button_widget.dart';
import 'package:hearbat/widgets/path/difficulty_selection_widget.dart';
import 'sound_alternating_path_layout_widget.dart';

class SoundModuleListWidget extends StatelessWidget {
  final Map<String, Module> modules;
  final String chapter;
  SoundModuleListWidget(
      {super.key, required this.modules, required this.chapter});

  @override
  Widget build(BuildContext context) {
    var moduleList = modules.entries.toList();
    void navigate(String moduleName, List<AnswerGroup> answerGroups) {
      print("Navigating to chapter: $chapter");
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => DifficultySelectionWidget(
            moduleName: moduleName,
            chapter: chapter,
            answerGroups: answerGroups,
            isWord: false,
            displayDifficulty: false,
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
                    answerGroups: module.value.answerGroups,
                    onButtonPressed: (String key, List<dynamic> value) {
                      navigate(key, value.cast<AnswerGroup>());
                    }),
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

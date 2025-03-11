import 'package:flutter/material.dart';
import 'package:hearbat/data/answer_pair.dart';
import 'package:hearbat/widgets/path/animated_button_widget.dart';
import 'package:hearbat/widgets/path/difficulty_selection_widget.dart';
import '../module/module_widget.dart';
import 'sound_trangular_path_layout_widget.dart';

class SoundModuleListWidget extends StatelessWidget {
  final Map<String, List<AnswerGroup>> modules;

  SoundModuleListWidget({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    var moduleList = modules.entries.toList();
    void navigate(String moduleName, List<AnswerGroup> answerGroups) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DifficultySelectionWidget(
            moduleName: moduleName,
            answerGroups: answerGroups,
            isWord: false,
            displayDifficulty: false,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SoundTriangularPathLayout(
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
                    answerGroups: module.value,
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

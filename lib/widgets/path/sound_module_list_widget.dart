import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/widgets/path/animated_button_widget.dart';
import '../module/module_widget.dart';
import 'sound_trangular_path_layout_widget.dart';

class SoundModuleListWidget extends StatelessWidget {
  //final Map<String, List<AnswerGroup>> modules;

  final Map<String, Module> modules;
  SoundModuleListWidget({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    var moduleList = modules.entries.toList();
    void navigate(String moduleName, List<AnswerGroup> answerGroups) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModuleWidget(
            title: moduleName,
            answerGroups: answerGroups,
            isWord: false,
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

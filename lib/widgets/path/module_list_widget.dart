import 'package:flutter/material.dart';
import 'package:hearbat/widgets/path/difficulty_selection_widget.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/widgets/path/module_button_with_progress.dart';
import 'alternating_path_layout_widget.dart';

class ModuleListWidget extends StatefulWidget {
  final Map<String, Module> modules;
  final String chapter;
  final String exerciseType;

  ModuleListWidget(
      {super.key,
      required this.modules,
      required this.chapter,
      required this.exerciseType});

  @override
  ModuleListWidgetState createState() => ModuleListWidgetState();
}

class ModuleListWidgetState extends State<ModuleListWidget>
    with TickerProviderStateMixin {
  void navigate(String moduleName, List<AnswerGroup> answerGroups) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => DifficultySelectionWidget(
          moduleName: moduleName,
          chapter: widget.chapter,
          exerciseType: widget.exerciseType,
          answerGroups: answerGroups,
          isWord: true,
          displayDifficulty: true,
          displayVoice: true,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var moduleList = widget.modules.entries.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: 
            AlternatingPathLayout(
          itemCount: moduleList.length,
          itemBuilder: (context, index) {
            final module = moduleList[index];
            return ModuleButtonWithProgress(
              moduleName: module.key,
              answerGroups: module.value.answerGroups,
              onButtonPressed: navigate,
              filledSections: 1,
              totalSections: 3,
            );
          },
          itemSize: 120.0,
          chapter: widget.chapter,
        ),
      ),
    );
  }
}

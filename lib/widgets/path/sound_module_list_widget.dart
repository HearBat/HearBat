import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/stats/exercise_score_model.dart';
import 'package:hearbat/widgets/path/difficulty_selection_widget.dart';
import 'package:hearbat/widgets/path/module_button_with_progress.dart';
import 'sound_alternating_path_layout_widget.dart';

class SoundModuleListWidget extends StatefulWidget {
  final Map<String, Module> modules;
  final String chapter;
  
  SoundModuleListWidget({
    super.key, 
    required this.modules, 
    required this.chapter
  });

  @override
  SoundModuleListWidgetState createState() => SoundModuleListWidgetState();
}

class SoundModuleListWidgetState extends State<SoundModuleListWidget> {
  
  Future<Map<String, int>> _loadModuleProgress() async {
    Map<String, int> progress = {};
    for (String moduleName in widget.modules.keys) {
      String fullName = '${widget.chapter} $moduleName';
      int completions = await ExerciseScore.getHighScoreCompletions(fullName);
      int clampedCompletions = completions.clamp(0, 3);
      progress[moduleName] = clampedCompletions;
    }
    return progress;
  }

  void navigate(String moduleName, List<AnswerGroup> answerGroups) {
    print("Navigating to chapter: ${widget.chapter}");
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => DifficultySelectionWidget(
          moduleName: moduleName,
          chapter: widget.chapter,
          exerciseType: "sounds",
          answerGroups: answerGroups,
          isWord: false,
          displayDifficulty: false,
          displayVoice: false,
        ),
        fullscreenDialog: true,
      ),
    )
        .then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FutureBuilder<Map<String, int>>(
          future: _loadModuleProgress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            
            if (snapshot.hasError) {
              return Text('Error loading progress: ${snapshot.error}');
            }
            
            final moduleProgress = snapshot.data ?? {};
            var moduleList = widget.modules.entries.toList();
            
            return SoundAlternatingPathLayout(
              itemCount: moduleList.length,
              itemBuilder: (context, index) {
                final module = moduleList[index];
                final filledSections = moduleProgress[module.key] ?? 0;
                
                return ModuleButtonWithProgress(
                  moduleName: module.key,
                  answerGroups: module.value.answerGroups,
                  onButtonPressed: navigate,
                  filledSections: filledSections,
                );
              },
              itemSize: 120.0,
            );
          },
        ),
      ),
    );
  }
}
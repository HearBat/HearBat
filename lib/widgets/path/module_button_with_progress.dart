import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'alternating_path_layout_widget.dart';
import 'animated_button_widget.dart';

class ModuleButtonWithProgress extends StatelessWidget {
  final String moduleName;
  final String moduleDescription;
  final List<dynamic> answerGroups;
  final void Function(String, List<AnswerGroup>) onButtonPressed;
  final int filledSections;

  const ModuleButtonWithProgress({
    super.key,
    required this.moduleName,
    required this.answerGroups,
    required this.onButtonPressed,
    required this.filledSections,
    required this.moduleDescription
  });

  @override
  Widget build(BuildContext context) {
    const double baseWidth = 100 * 1.2;

    return SizedBox(
      width: baseWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedButton(
                moduleName: moduleName,
                moduleDescription: moduleDescription,
                answerGroups: answerGroups,
                onButtonPressed: (k, v) => onButtonPressed(k, v.cast<AnswerGroup>()),
              ),
            ],
          ),
          const SizedBox(height: 60),
          ModuleProgressBar(
            filledSections: filledSections,
            totalSections: 3,
          ),
        ],
      ),
    );
  }
}

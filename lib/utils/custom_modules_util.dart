import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/translations.dart';
import '../widgets/module/module_widget.dart';
import 'package:hearbat/utils/cache_words_util.dart';
// import '../../../../utils/gemini_util.dart';

class CustomModule extends StatefulWidget {
  final String moduleName;
  final List<AnswerGroup> answerGroups;
  final String voiceType;

  CustomModule({
    required this.moduleName,
    required this.answerGroups,
    required this.voiceType,
  });

  @override
  CustomModuleState createState() => CustomModuleState();
}

class CustomModuleState extends State<CustomModule> {
  final CacheWordsUtil cacheUtil = CacheWordsUtil();
  bool isCaching = false;

  @override
  void initState() {
    super.initState();
    cacheWords();
  }

  // Caches words before displaying the module.
  Future<void> cacheWords() async {
    setState(() {
      isCaching = true; // Show loading indicator
    });

    await cacheUtil.cacheModuleWords(widget.answerGroups, widget.voiceType);

    if (mounted) {
      setState(() {
        isCaching = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCaching) {
      // Show loading screen while caching
      return Scaffold(
        body: Center(
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text(AppLocale.generalLoading.getString(context)),
              ],
            ),
          ),
        ),
      );
    }

    // Once caching is done, show the WordModuleWidget
    return ModuleWidget(
      title: widget.moduleName,
      answerGroups: widget.answerGroups,
      isWord: true,
    );
  }
}

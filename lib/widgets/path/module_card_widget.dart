// this is for the module cards when you click on view words in the path
// holding the respective words that are in the modules
import 'package:flutter/material.dart';
import 'package:hearbat/data/answer_pair.dart';
import '../../pages/module_types/words/module_words_page.dart';
import 'package:hearbat/utils/cache_words_util.dart';

class ModuleCard extends StatefulWidget {
  final String moduleName;
  final List<AnswerGroup> answerGroups;
  final String voiceType;

  const ModuleCard({
    super.key,
    required this.moduleName,
    required this.answerGroups,
    required this.voiceType,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  final CacheWordsUtil cacheUtil = CacheWordsUtil();
  double elevation = 5.0;

  Future<void> _cacheAndNavigate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    await cacheUtil.cacheModuleWords(widget.answerGroups, widget.voiceType);

    if (!mounted) return;

    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleWordsPage(
          moduleName: widget.moduleName,
          answerGroups: widget.answerGroups,
          voiceType: widget.voiceType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.5;

    return GestureDetector(
      onTapDown: (_) => setState(() => elevation = 2.0),
      onTapUp: (_) {
        setState(() => elevation = 5.0);
        _cacheAndNavigate();
      },
      onTapCancel: () => setState(() => elevation = 5.0),
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.all(8),
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 7, 45, 78),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  widget.moduleName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => elevation = 5.0);
                        _cacheAndNavigate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 45, 78),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text(
                        "HEAR WORDS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

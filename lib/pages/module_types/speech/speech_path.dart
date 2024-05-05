import 'package:flutter/material.dart';
import 'package:hearbat/widgets/path/speech_module_list_widget.dart';
import '../../../utils/module_util.dart';
import '../../../widgets/top_bar_widget.dart';

class SpeechPath extends StatefulWidget {
  final String chapter;

  SpeechPath({Key? key, required this.chapter}) : super(key: key);

  @override
  State<SpeechPath> createState() => _SpeechPathState();
}

class _SpeechPathState extends State<SpeechPath> {
  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> modules = getModulesForSpeech(widget.chapter);
    return Scaffold(
      appBar: TopBar(
        title: widget.chapter.toUpperCase(),
        leadingIcon: Icons.west,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.9, 1.0],
            colors: [
              Color.fromARGB(255, 212, 176, 237),
              Color.fromARGB(255, 251, 191, 203),
              Color.fromARGB(255, 255, 238, 247),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              alignment: FractionalOffset(-0.35, 0.05),
              child: Container(
                width: 200,
                height: 80,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/visuals/cloud1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              alignment: FractionalOffset(1.4, 0.15),
              child: Container(
                width: 200,
                height: 80,
                child: Opacity(
                  opacity: 0.65,
                  child: Image.asset(
                    'assets/visuals/cloud1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              alignment: FractionalOffset(1.8, 0.3),
              child: Container(
                width: 300,
                height: 120,
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    'assets/visuals/cloud1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              alignment: FractionalOffset(-0.1, 0.5),
              child: Container(
                width: 200,
                height: 200,
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    'assets/visuals/cloud1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              alignment: FractionalOffset(1.2, 0.7),
              child: Container(
                width: 200,
                height: 200,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/visuals/cloud1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              alignment: FractionalOffset(0.5, 0.95),
              child: Container(
                width: 300,
                height: 150,
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    'assets/visuals/cloud1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SpeechModuleListWidget(modules: modules),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

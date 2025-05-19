import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import '../../../utils/data_service_util.dart';
import '../../../widgets/path/module_list_widget.dart';
import '../../../widgets/top_bar_widget.dart';

class WordPath extends StatefulWidget {
  final String chapter;

  WordPath({super.key, required this.chapter});

  @override
  State<WordPath> createState() => _WordPathState();
}

class _WordPathState extends State<WordPath> {
  double elevation = 5.0;

  @override
  Widget build(BuildContext context) {
    Map<String, Module> modules = DataService().getWordChapter(widget.chapter).modules;
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
              child: SizedBox(
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
              child: SizedBox(
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
              child: SizedBox(
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
              child: SizedBox(
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
              child: SizedBox(
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
              child: SizedBox(
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
                  child: ModuleListWidget(
                      modules: modules,
                      chapter: widget.chapter,
                      exerciseType: "words",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

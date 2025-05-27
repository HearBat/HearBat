import 'package:flutter/material.dart';

import 'package:hearbat/stats/answer_model.dart';
import 'package:hearbat/utils/translations.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:hearbat/widgets/insight/missed_answer_widget.dart';

class MissedAnswersPage extends StatefulWidget {
  final String type;
  final int count;

  MissedAnswersPage({
    required this.type,
    this.count = 10,
    super.key
  });

  @override
  MissedAnswersPageState createState() => MissedAnswersPageState();
}

class MissedAnswersPageState extends State<MissedAnswersPage> {
  List<Answer> _missedAnswers = [];

  Future<void> _loadMissedAnswers() async {
    final missedAnswers = await Answer.getMostMissed(widget.type, widget.count);

    setState(() {
      _missedAnswers = missedAnswers;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMissedAnswers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: AppLocale.insightsPageTitle.getString(context)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
            Column(
              children: [
                Text(
                  widget.type == "sounds" ?
                    AppLocale.missedSoundsPageMostMissedSounds.getString(context) :
                    AppLocale.missedWordsPageMostMissedWords.getString(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _missedAnswers.isEmpty
                  ? Center(child: Text(
                    widget.type == "sounds" ?
                      AppLocale.missedSoundsPageEmpty.getString(context) :
                      AppLocale.missedWordsPageEmpty.getString(context)))
                  : Expanded(
                    child: ListView.builder(
                      itemCount: _missedAnswers.length,
                      padding: EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        final answer = _missedAnswers[index];
                        return MissedAnswerWidget(word: answer.name, missCount: answer.incorrect!);
                      }
                    ),
                  ),
              ],
            ),
          ),
      ),
    );
  }
}
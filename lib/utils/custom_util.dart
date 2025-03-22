import 'package:flutter/material.dart';
import 'package:hearbat/utils/user_module_util.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import '../utils/gemini_util.dart';
import '../utils/text_util.dart';

// Utility for creating and saving custom learning modules.
class CustomUtil extends StatefulWidget {
  final Function(String) onModuleSaved;

  CustomUtil({required this.onModuleSaved});

  @override
  CustomUtilState createState() => CustomUtilState();
}

class CustomUtilState extends State<CustomUtil> {
  List<TextEditingController> _controllers = [
    TextEditingController(), // Initial Word A1
    TextEditingController(), // Initial Word A2
    TextEditingController(), // Initial Word A3
    TextEditingController(), // Initial Word A4
  ];
  TextEditingController _moduleNameController = TextEditingController();

  // Adds a new set of four word input fields.
  void _addNewPair() {
    if (_controllers.length < 40) {
      setState(() {
        _controllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
      });
    }
  }

  // Removes a set of four word input fields.
  void _removePair(int index) {
    if (_controllers.length > 4) {
      setState(() {
        _controllers.removeRange(index, index + 4);
      });
    }
  }

  // Saves the custom module with provided words, generating missing ones if needed.
  void _saveModule() async {
    List<AnswerGroup> answerGroups = [];
    for (int i = 0; i < _controllers.length; i += 4) {
      String answer1 = capitalizeWord(_controllers[i].text.trim());
      String answer2 = capitalizeWord(_controllers[i + 1].text.trim());
      String answer3 = capitalizeWord(_controllers[i + 2].text.trim());
      String answer4 = capitalizeWord(_controllers[i + 3].text.trim());

      if (answer1.isNotEmpty &&
          answer2.isNotEmpty &&
          answer3.isNotEmpty &&
          answer4.isNotEmpty) {
        // Creates a complete answer group.
        AnswerGroup group = AnswerGroup([
          Answer(answer1, "", ""),
          Answer(answer2, "", ""),
          Answer(answer3, "", ""),
          Answer(answer4, "", ""),
        ]);
        answerGroups.add(group);
      } else if (answer1.isNotEmpty ||
          answer2.isNotEmpty ||
          answer3.isNotEmpty ||
          answer4.isNotEmpty) {
        // Collects words to generate missing ones.
        List<String> wordsToBeCompared = [];
        if (answer1.isNotEmpty) {
          wordsToBeCompared.add(answer1);
        }
        if (answer2.isNotEmpty) {
          wordsToBeCompared.add(answer2);
        }
        if (answer3.isNotEmpty) {
          wordsToBeCompared.add(answer3);
        }
        if (answer4.isNotEmpty) {
          wordsToBeCompared.add(answer4);
        }

        String llmOutput = await GeminiUtil.generateContent(wordsToBeCompared);
        List<String> words = llmOutput.split('\n');

        for (String word in words) {
          String trimmedWord = word.trim();
          trimmedWord = stripNonAlphaCharacters(trimmedWord);
          if (trimmedWord.isNotEmpty) {
            wordsToBeCompared.add(trimmedWord);
          }
        }

        // Ensures we have a complete set of four words.
        if (wordsToBeCompared.length == 4) {
          AnswerGroup group = AnswerGroup([
            Answer(wordsToBeCompared[0], "", ""),
            Answer(wordsToBeCompared[1], "", ""),
            Answer(wordsToBeCompared[2], "", ""),
            Answer(wordsToBeCompared[3], "", ""),
          ]);
          answerGroups.add(group);
        } else {
          print("Not enough words");
        }
      }
    }

    // Saves the module if the name and answer groups are valid.
    String moduleName = _moduleNameController.text.trim();
    if (moduleName.isNotEmpty && answerGroups.isNotEmpty) {
      try {
        await UserModuleUtil.saveCustomModule(moduleName, answerGroups);
        if (!mounted) return;
        widget.onModuleSaved(moduleName);
        print("Module saved successfully!");
      } catch (e) {
        print("Failed to save module: $e");
      }
    } else {
      print("Incomplete input. Ensure all fields are filled and try again.");
    }
  }

  // Builds the UI for the module creator.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar displaying the module title.
      appBar: TopBar(
        title: "Module Creator",
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30),
          // Title text for the module creation screen.
          Text(
            "Enter your desired words!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 7, 45, 78),
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Instruction text explaining automatic word filling.
          Text(
            "We'll fill in the rest of your set if\nyou enter less than four words",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 7, 45, 78),
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          // Input field for the module name.
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: TextField(
              controller: _moduleNameController,
              decoration: InputDecoration(
                labelText: "Module Name",
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 174, 130, 255),
                    width: 3.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 83, 83, 83),
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          // Dynamically generates input fields for each word set.
          ...List.generate(
            _controllers.length ~/ 4,
            (index) => Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Displays the set number.
                      Expanded(
                        child: Text(
                          'Set ${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // Delete button for removing a word set.
                      Visibility(
                        visible: _controllers.length > 4,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          alignment: Alignment.centerRight,
                          onPressed: () => _removePair(index * 4),
                        ),
                      ),
                    ],
                  ),
                  // Input fields for four words in the set.
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controllers[index * 4],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 174, 130, 255),
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 83, 83, 83),
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controllers[index * 4 + 1],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 174, 130, 255),
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 83, 83, 83),
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controllers[index * 4 + 2],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 174, 130, 255),
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 83, 83, 83),
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controllers[index * 4 + 3],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 174, 130, 255),
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 83, 83, 83),
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Button to add a new word set if under limit.
          if (_controllers.length < 40)
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              child: ElevatedButton.icon(
                onPressed: _addNewPair,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  'Add Set',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 94, 224, 82),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: ElevatedButton(
              onPressed: _saveModule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 154, 107, 187),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
              child: Text(
                "Save Module",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hearbat/utils/translations.dart';
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
  final TextEditingController _moduleNameController = TextEditingController();
  List<TextEditingController> _controllers = [
    TextEditingController(), // Initial Word A1
    TextEditingController(), // Initial Word A2
    TextEditingController(), // Initial Word A3
    TextEditingController(), // Initial Word A4
  ];

  @override
  void initState() {
    super.initState();
    // Listen for any typing to force PopScope rebuild
    _moduleNameController.addListener(() => setState(() {}));
    for (var c in _controllers) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _moduleNameController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    if (_moduleNameController.text.trim().isNotEmpty) return true;
    return _controllers.any((c) => c.text.trim().isNotEmpty);
  }

  Future<bool> _confirmDiscard() async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocale.editCustomModuleDiscardChanges.getString(context),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 7, 45, 78),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocale.editCustomModuleUnsavedChangesWarning.getString(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 7, 45, 78),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 123, 225, 114),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocale.editCustomModuleKeepEditing.getString(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A2140),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'DISCARD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      );
    },
  );
  return result ?? false;
}


  // Adds a new set of four word input fields.
  void _addNewPair() {
    if (_controllers.length < 40) {
      setState(() {
        var newFields = List.generate(4, (_) => TextEditingController());
        for (var c in newFields) {
          c.addListener(() => setState(() {}));
        }
        _controllers.addAll(newFields);
      });
    }
  }

  // Removes a set of four word input fields.
  void _removePair(int index) {
    if (_controllers.length > 4) {
      setState(() {
        for (int i = index; i < index + 4; i++) {
          _controllers[i].dispose();
        }
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
        answerGroups.add(AnswerGroup([
          Answer(answer1, "", ""),
          Answer(answer2, "", ""),
          Answer(answer3, "", ""),
          Answer(answer4, "", ""),
        ]));
      } else if (answer1.isNotEmpty ||
          answer2.isNotEmpty ||
          answer3.isNotEmpty ||
          answer4.isNotEmpty) {
        List<String> seed = [];
        if (answer1.isNotEmpty) seed.add(answer1);
        if (answer2.isNotEmpty) seed.add(answer2);
        if (answer3.isNotEmpty) seed.add(answer3);
        if (answer4.isNotEmpty) seed.add(answer4);

        try {
          String llmOutput = await GeminiUtil.generateContent(seed);
          List<String> extras = llmOutput
              .split('\n')
              .map((w) => stripNonAlphaCharacters(w.trim()))
              .where((w) => w.isNotEmpty)
              .toList();
          seed.addAll(extras);
          if (seed.length >= 4) {
            answerGroups.add(AnswerGroup([
              Answer(seed[0], "", ""),
              Answer(seed[1], "", ""),
              Answer(seed[2], "", ""),
              Answer(seed[3], "", ""),
            ]));
          }
        } catch (_) {
          // optionally show snackbar
        }
      }
    }

    String moduleName = _moduleNameController.text.trim();
    if (moduleName.isEmpty || answerGroups.isEmpty) {
      print("Incomplete input. Ensure all fields are filled and try again.");
      return;
    }

    bool moduleExists = await UserModuleUtil.doesModuleExist(moduleName);
    if (moduleExists) {
      if (!mounted) return;
      bool shouldOverwrite = await showDialog<bool>(
            context: context,
            builder: (context) => Dialog(
              insetPadding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.7),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocale.customUtilAlreadyExists.getString(context),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppLocale.customUtilOverwritePrompt.getString(context),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 154, 107, 187),
                              minimumSize: Size(120, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              AppLocale.customUtilReturnToModule.getString(context),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(120, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocale.customUtilOverwrite.getString(context),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ) ??
          false;
      if (!shouldOverwrite) return;
    }

    try {
      await UserModuleUtil.saveCustomModule(moduleName, answerGroups);
      if (!mounted) return;
      widget.onModuleSaved(moduleName);
      print("Module saved successfully!");
      _moduleNameController.clear();
      for (var c in _controllers) {
        c.clear();
      }
      setState(() {});
    } catch (e) {
      print("Failed to save module: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: TopBar(title: AppLocale.customUtilTitle.getString(context)),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 30),
            Text(
              AppLocale.customUtilEntryPrompt.getString(context),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 7, 45, 78),
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              AppLocale.customUtilFillTheRest.getString(context),
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 7, 45, 78),
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: TextField(
                controller: _moduleNameController,
                decoration: InputDecoration(
                  labelText: AppLocale.customUtilModuleName.getString(context),
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
            ...List.generate(
              _controllers.length ~/ 4,
              (index) => Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${AppLocale.editCustomModuleSet.getString(context)} ${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
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
                    AppLocale.editCustomModuleAddSet.getString(context),
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
                  AppLocale.customUtilSaveModule.getString(context),
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
      ),
    );
  }
}

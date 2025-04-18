import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import 'package:hearbat/utils/gemini_util.dart';
import 'package:hearbat/utils/user_module_util.dart';
import '../utils/text_util.dart';

class EditModuleScreen extends StatefulWidget {
  final String moduleName;
  final Function? onModuleDeleted;

  const EditModuleScreen({
    super.key,
    required this.moduleName,
    this.onModuleDeleted,
  });

  @override
  State<EditModuleScreen> createState() => _EditModuleScreenState();
}

class _EditModuleScreenState extends State<EditModuleScreen> {
  List<AnswerGroup> answerGroups = [];
  bool isLoading = true;
  bool hasEmptyFields = false;
  bool hasUnsavedChanges = false;
  Map<String, TextEditingController> controllers = {};
  final int maxGroups = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAnswerGroups();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAnswerGroups() async {
    setState(() {
      isLoading = true;
    });

    List<AnswerGroup> groups =
        await UserModuleUtil.getCustomModuleAnswerGroups(widget.moduleName);

    for (int i = 0; i < groups.length; i++) {
      var group = groups[i];
      for (int j = 0; j < group.answers.length; j++) {
        _initControllerForAnswer(i, j + 1, group.answers[j].answer);
      }
    }

    setState(() {
      answerGroups = groups;
      isLoading = false;
      hasUnsavedChanges = false;
      _checkForEmptyFields();
    });
  }

  void _initControllerForAnswer(int groupIndex, int answerIndex, String text) {
    String key = 'group_${groupIndex}_answer_$answerIndex';
    controllers[key] = TextEditingController(text: text);

    controllers[key]!.addListener(() {
      _updateModelFromController(groupIndex, answerIndex);
    });
  }

  void _updateModelFromController(int groupIndex, int answerIndex) {
    if (groupIndex >= answerGroups.length) return;

    String key = 'group_${groupIndex}_answer_$answerIndex';
    if (!controllers.containsKey(key)) return;

    String value = controllers[key]!.text;
    String capitalizedValue = capitalizeWord(value);

    AnswerGroup currentGroup = answerGroups[groupIndex];
    AnswerGroup updatedGroup;

    List<Answer> updatedAnswers = List.from(currentGroup.answers);

    if (answerIndex >= 1 && answerIndex <= updatedAnswers.length) {
      Answer updatedAnswer = Answer(
        capitalizedValue,
        updatedAnswers[answerIndex - 1].path,
        updatedAnswers[answerIndex - 1].image,
      );
      updatedAnswers[answerIndex - 1] = updatedAnswer;
    }

    updatedGroup = AnswerGroup(updatedAnswers);

    List<AnswerGroup> newList = List<AnswerGroup>.from(answerGroups);
    newList[groupIndex] = updatedGroup;

    hasUnsavedChanges = true;
    answerGroups = newList;

    _debouncedCheckEmptyFields();
  }

  bool _checkScheduled = false;
  Future<void> _debouncedCheckEmptyFields() async {
    if (_checkScheduled) return;
    _checkScheduled = true;

    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _checkForEmptyFields();
        _checkScheduled = false;
      });
    }
  }

  void _checkForEmptyFields() {
    bool isEmpty = false;

    for (var group in answerGroups) {
      for (var answer in group.answers) {
        if (answer.answer.trim().isEmpty) {
          isEmpty = true;
          break;
        }
      }
      if (isEmpty) {
        break;
      }
    }

    hasEmptyFields = isEmpty;
  }

  void _addAnswerGroup() {
    if (answerGroups.length >= maxGroups) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of $maxGroups groups allowed')),
      );
      return;
    }


    List<Answer> emptyAnswers = List.generate(4, (index) => Answer("", "", ""));
    AnswerGroup newGroup = AnswerGroup(emptyAnswers);

    int newIndex = answerGroups.length;
    _initControllerForAnswer(newIndex, 1, "");
    _initControllerForAnswer(newIndex, 2, "");
    _initControllerForAnswer(newIndex, 3, "");
    _initControllerForAnswer(newIndex, 4, "");

    setState(() {
      answerGroups.add(newGroup);
      hasUnsavedChanges = true;
      hasEmptyFields = true;
    });

    // Scroll to the new group
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeControllersForGroup(int groupIndex) {
    for (int i = 1; i <= 4; i++) {
      String key = 'group_${groupIndex}_answer_$i';
      if (controllers.containsKey(key)) {
        controllers[key]!.dispose();
        controllers.remove(key);
      }
    }
  }

  void _rebuildControllersForGroup(int newGroupIndex, AnswerGroup group) {
    for (int i = 0; i < group.answers.length; i++) {
      _initControllerForAnswer(newGroupIndex, i + 1, group.answers[i].answer);
    }
  }

  Future<void> _deleteAnswerGroup(int visualIndex) async {
    if (visualIndex < 0 || visualIndex >= answerGroups.length) {
      return;
    }

    if (answerGroups.length == 1) {
      bool confirmed = await _showDeleteConfirmationDialog("Delete Module",
          "This is the last answer group. Deleting it will remove the entire module. Continue?");

      if (confirmed && mounted) {
        setState(() {
          isLoading = true;
        });

        // Clean up controllers for this group
        _removeControllersForGroup(0);

        setState(() {
          answerGroups = [];
          hasUnsavedChanges = true;
        });

        await UserModuleUtil.deleteCustomModule(widget.moduleName);

        if (mounted) {
          if (widget.onModuleDeleted != null) {
            widget.onModuleDeleted!();
          }
          Navigator.of(context).pop();
        }
      }
    } else {
      bool confirmed = await _showDeleteConfirmationDialog(
          "Delete Group", "Are you sure you want to delete this answer group?");

      if (confirmed && mounted) {
        _removeControllersForGroup(visualIndex);

        List<AnswerGroup> newList = List<AnswerGroup>.from(answerGroups);
        newList.removeAt(visualIndex);

        for (int i = visualIndex; i < newList.length; i++) {
          _rebuildControllersForGroup(i, newList[i]);
        }

        setState(() {
          answerGroups = newList;
          hasUnsavedChanges = true;
          _checkForEmptyFields();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Group deleted (unsaved)')),
          );
        }
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(
      String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _saveModule() async {
    setState(() {
      isLoading = true;
    });

    List<AnswerGroup> finalAnswerGroups = [];

    // Process each answer group
    for (int i = 0; i < answerGroups.length; i++) {
      AnswerGroup group = answerGroups[i];

      List<String> answers = group.answers.map((answer) => answer.answer.trim()).toList();

      // Check if all answers are non-empty
      if (answers.every((answer) => answer.isNotEmpty)) {
        finalAnswerGroups.add(group);
      } else if (answers.any((answer) => answer.isNotEmpty)) {
        // If some answers are non-empty, generate missing words
        List<String> existingWords = answers.where((answer) => answer.isNotEmpty).toList();

        try {
          String llmOutput = await GeminiUtil.generateContent(existingWords);
          List<String> generatedWords = llmOutput.split('\n');

          List<String> allWords = [...existingWords];

          for (String word in generatedWords) {
            String trimmedWord = word.trim();
            trimmedWord = stripNonAlphaCharacters(trimmedWord);
            if (trimmedWord.isNotEmpty && !allWords.contains(trimmedWord)) {
              allWords.add(trimmedWord);
              if (allWords.length == 4) break;
            }
          }

          if (allWords.length == 4) {
            List<Answer> completeAnswers = allWords
                .map((word) => Answer(capitalizeWord(word), "", ""))
                .toList();
            AnswerGroup completeGroup = AnswerGroup(completeAnswers);
            finalAnswerGroups.add(completeGroup);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Could not generate enough related words for group ${i + 1}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error generating words for group ${i + 1}: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    if (finalAnswerGroups.isNotEmpty) {
      await UserModuleUtil.saveCustomModule(
          widget.moduleName, finalAnswerGroups);

      if (mounted) {
        setState(() {
          answerGroups = finalAnswerGroups;
          isLoading = false;
          hasUnsavedChanges = false;
        });

        for (int i = 0; i < finalAnswerGroups.length; i++) {
          var group = finalAnswerGroups[i];
          for (int j = 0; j < group.answers.length; j++) {
            _updateControllerWithoutListener(i, j + 1, group.answers[j].answer);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Module saved successfully')),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No valid answer groups to save. Please add at least one word.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateControllerWithoutListener(
      int groupIndex, int answerIndex, String text) {
    String key = 'group_${groupIndex}_answer_$answerIndex';
    if (controllers.containsKey(key)) {
      controllers[key]!.removeListener(() {
        _updateModelFromController(groupIndex, answerIndex);
      });

      controllers[key]!.text = text;

      controllers[key]!.addListener(() {
        _updateModelFromController(groupIndex, answerIndex);
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;
    if (!mounted) return false;

    final BuildContext currentContext = context;

    final result = await showDialog<bool>(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: Text('Discard changes?'),
        content:
            Text('You have unsaved changes. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              await _saveModule();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: Text('Save and Exit'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.moduleName),
          actions: [
            if (hasUnsavedChanges)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    'Unsaved changes',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveModule,
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : answerGroups.isEmpty
                ? Center(child: Text('No answer groups found for this module'))
                : Column(
                    children: [
                      Expanded(
                          child: ListView.builder(
                        controller: _scrollController,
                        itemCount: answerGroups.length,
                        itemBuilder: (context, index) {
                          final uniqueId = 'group_$index';
                          return _buildAnswerGroupCard(index,
                              key: ValueKey(uniqueId));
                        },
                      )),
                      if (answerGroups.length < maxGroups)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton.icon(
                            onPressed: _addAnswerGroup,
                            icon: Icon(Icons.add, color: Colors.white),
                            label: Text(
                              'Add Set',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 94, 224, 82),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAnswerGroupCard(int groupIndex, {Key? key}) {
    return Card(
      key: key,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Answer Group ${groupIndex + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAnswerGroup(groupIndex),
                  tooltip: 'Delete this group',
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildAnswerField(groupIndex, 1),
            _buildAnswerField(groupIndex, 2),
            _buildAnswerField(groupIndex, 3),
            _buildAnswerField(groupIndex, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerField(int groupIndex, int answerIndex) {
    String controllerKey = 'group_${groupIndex}_answer_$answerIndex';

    if (!controllers.containsKey(controllerKey)) {
      String initialValue = "";
      if (groupIndex < answerGroups.length) {
        AnswerGroup group = answerGroups[groupIndex];
        if (answerIndex >= 1 && answerIndex <= group.answers.length) {
          initialValue = group.answers[answerIndex - 1].answer;
        }
      }
      _initControllerForAnswer(groupIndex, answerIndex, initialValue);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        key: ValueKey(controllerKey),
        controller: controllers[controllerKey],
        decoration: InputDecoration(
          labelText: 'Answer $answerIndex',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

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
  Map<String, String> _originalTextValues = {};
  bool isLoading = true;
  bool hasEmptyFields = false;
  bool hasUnsavedChanges = false;
  Map<String, TextEditingController> controllers = {};
  final Map<String, FocusNode> focusNodes = {};
  final int maxGroups = 10;
  final ScrollController _scrollController = ScrollController();
  Map<String, VoidCallback> _listenerMap = {};

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

    // Store original text values by key
    for (int i = 0; i < groups.length; i++) {
      var group = groups[i];
      _originalTextValues['group_${i}_answer_1'] = group.answers[0].answer;
      _originalTextValues['group_${i}_answer_2'] = group.answers[1].answer;
      _originalTextValues['group_${i}_answer_3'] = group.answers[2].answer;
      _originalTextValues['group_${i}_answer_4'] = group.answers[3].answer;

      _initControllerForAnswer(i, 1, group.answers[0].answer);
      _initControllerForAnswer(i, 2, group.answers[1].answer);
      _initControllerForAnswer(i, 3, group.answers[2].answer);
      _initControllerForAnswer(i, 4, group.answers[3].answer);
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

    focusNodes[key] = FocusNode()
      ..addListener(() {
        setState(
            () {}); // literally only for the circles + icons to disappear when you select focus
      });

    _listenerMap[key] = () {
      _updateModelFromController(groupIndex, answerIndex);
    };

    controllers[key]!.addListener(_listenerMap[key]!);
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

    answerGroups = newList;

    _debouncedCheckHasUnsavedChanges();
    _debouncedCheckEmptyFields();
  }

  void _checkHasUnsavedChanges() {
    if (answerGroups.length != _originalTextValues.length / 4) {
      setState(() {
        hasUnsavedChanges = true;
      });
      return;
    }

    for (int i = 0; i < answerGroups.length; i++) {
      for (int j = 1; j <= 4; j++) {
        String key = 'group_${i}_answer_$j';
        if (!controllers.containsKey(key) ||
            !_originalTextValues.containsKey(key)) {
          setState(() {
            hasUnsavedChanges = true;
          });
          return;
        }

        String currentText = controllers[key]!.text;
        String originalText = _originalTextValues[key]!;

        if (currentText != originalText) {
          setState(() {
            hasUnsavedChanges = true;
          });
          return;
        }
      }
    }

    // If we get here, no changes found
    setState(() {
      hasUnsavedChanges = false;
    });
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

  bool _checkChangesScheduled = false;
  Future<void> _debouncedCheckHasUnsavedChanges() async {
    if (_checkChangesScheduled) return;
    _checkChangesScheduled = true;

    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      _checkHasUnsavedChanges();
      _checkChangesScheduled = false;
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
      hasEmptyFields = true;
    });

    _debouncedCheckHasUnsavedChanges();

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
        });

        _debouncedCheckHasUnsavedChanges();

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
          _removeControllersForGroup(i + 1);
          _rebuildControllersForGroup(i, newList[i]);
        }

        setState(() {
          answerGroups = newList;
          _checkForEmptyFields();
        });

        _debouncedCheckHasUnsavedChanges();

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

    for (int i = 0; i < answerGroups.length; i++) {
      AnswerGroup group = answerGroups[i];

      List<String> answers =
          group.answers.map((answer) => answer.answer.trim()).toList();

      if (answers.every((answer) => answer.isNotEmpty)) {
        finalAnswerGroups.add(group);
      } else if (answers.any((answer) => answer.isNotEmpty)) {
        List<String> existingWords =
            answers.where((answer) => answer.isNotEmpty).toList();

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
        _originalTextValues.clear();
        for (int i = 0; i < finalAnswerGroups.length; i++) {
          var group = finalAnswerGroups[i];
          _originalTextValues['group_${i}_answer_1'] = group.answers[0].answer;
          _originalTextValues['group_${i}_answer_2'] = group.answers[1].answer;
          _originalTextValues['group_${i}_answer_3'] = group.answers[2].answer;
          _originalTextValues['group_${i}_answer_4'] = group.answers[3].answer;
        }

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
    if (controllers.containsKey(key) && _listenerMap.containsKey(key)) {
      controllers[key]!.removeListener(_listenerMap[key]!);

      controllers[key]!.text = text;

      controllers[key]!.addListener(_listenerMap[key]!);
    }
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;
    if (!mounted) return false;

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
                    'Discard Changes?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 7, 45, 78),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You have unsaved changes.\nAre you sure you want to exit?',
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 123, 225, 114),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'KEEP EDITING',
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0A2140), // dark blue
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

  Widget _buildAnswerTile(int groupIndex, int answerIndex) {
    final key = 'group_${groupIndex}_answer_$answerIndex';
    final controller = controllers[key]!;
    final focusNode = focusNodes[key]!; // never null after init

    final showCircle = controller.text.isEmpty && !focusNode.hasFocus;

    return Container(
      width: (MediaQuery.of(context).size.width - 32 - 12) / 2,
      height: 72,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showCircle)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 7, 45, 78),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) {
              final capped = capitalizeWord(val);
              if (controller.text != capped) {
                controller.value = controller.value.copyWith(
                  text: capped,
                  selection: TextSelection.collapsed(offset: capped.length),
                );
              }
              _updateModelFromController(groupIndex, answerIndex);
            },
          ),
        ],
      ),
    );
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
          actions: [],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : answerGroups.isEmpty
                ? Center(child: Text('No answer groups found for this module'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: answerGroups.length +
                        (answerGroups.length < maxGroups ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == answerGroups.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: SizedBox(
                              width: 140,
                              child: ElevatedButton.icon(
                                onPressed: _addAnswerGroup,
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text('Add Set',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return _buildAnswerGroupCard(index,
                          key: ValueKey('group_$index'));
                    },
                  ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton(
            onPressed: (hasUnsavedChanges) ? _saveModule : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 94, 224, 82),
              disabledBackgroundColor: Colors.grey.shade400,
              disabledForegroundColor: Colors.white70,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'SAVE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerGroupCard(int groupIndex, {Key? key}) {
    return Container(
      key: key,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Set ${groupIndex + 1}:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Container(
                  width: 28, // narrower rectangle
                  height: 20, // shorter height
                  decoration: BoxDecoration(
                    color: Color(0xFF072D4E), // your blue
                    borderRadius: BorderRadius.circular(4), // slight rounding
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: 16, // smaller icon
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteAnswerGroup(groupIndex),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (i) => _buildAnswerTile(groupIndex, i + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

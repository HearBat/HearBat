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
      _originalTextValues['group_${i}_answer_1'] = group.answer1.answer;
      _originalTextValues['group_${i}_answer_2'] = group.answer2.answer;
      _originalTextValues['group_${i}_answer_3'] = group.answer3.answer;
      _originalTextValues['group_${i}_answer_4'] = group.answer4.answer;
      
      _initControllerForAnswer(i, 1, group.answer1.answer);
      _initControllerForAnswer(i, 2, group.answer2.answer);
      _initControllerForAnswer(i, 3, group.answer3.answer);
      _initControllerForAnswer(i, 4, group.answer4.answer);
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
    Answer updatedAnswer;
    AnswerGroup updatedGroup;

    switch (answerIndex) {
      case 1:
        updatedAnswer = Answer(capitalizedValue, currentGroup.answer1.path,
            currentGroup.answer1.image);
        updatedGroup = AnswerGroup(updatedAnswer, currentGroup.answer2,
            currentGroup.answer3, currentGroup.answer4);
      case 2:
        updatedAnswer = Answer(capitalizedValue, currentGroup.answer2.path,
            currentGroup.answer2.image);
        updatedGroup = AnswerGroup(currentGroup.answer1, updatedAnswer,
            currentGroup.answer3, currentGroup.answer4);
      case 3:
        updatedAnswer = Answer(capitalizedValue, currentGroup.answer3.path,
            currentGroup.answer3.image);
        updatedGroup = AnswerGroup(currentGroup.answer1, currentGroup.answer2,
            updatedAnswer, currentGroup.answer4);
      case 4:
        updatedAnswer = Answer(capitalizedValue, currentGroup.answer4.path,
            currentGroup.answer4.image);
        updatedGroup = AnswerGroup(currentGroup.answer1, currentGroup.answer2,
            currentGroup.answer3, updatedAnswer);
      default:
        return;
    }

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
        if (!controllers.containsKey(key) || !_originalTextValues.containsKey(key)) {
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
      if (group.answer1.answer.trim().isEmpty ||
          group.answer2.answer.trim().isEmpty ||
          group.answer3.answer.trim().isEmpty ||
          group.answer4.answer.trim().isEmpty) {
        isEmpty = true;
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

    // this looks cursed
    AnswerGroup newGroup = AnswerGroup(
      Answer("", "", ""),
      Answer("", "", ""),
      Answer("", "", ""),
      Answer("", "", ""),
    );

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
    _initControllerForAnswer(newGroupIndex, 1, group.answer1.answer);
    _initControllerForAnswer(newGroupIndex, 2, group.answer2.answer);
    _initControllerForAnswer(newGroupIndex, 3, group.answer3.answer);
    _initControllerForAnswer(newGroupIndex, 4, group.answer4.answer);
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

        // Update controllers for groups after the deleted one
        for (int i = visualIndex; i < newList.length; i++) {
          _removeControllersForGroup(i + 1); // Remove old controllers
          _rebuildControllersForGroup(i, newList[i]); // Rebuild with new index
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

      String answer1 = group.answer1.answer.trim();
      String answer2 = group.answer2.answer.trim();
      String answer3 = group.answer3.answer.trim();
      String answer4 = group.answer4.answer.trim();

      if (answer1.isNotEmpty &&
          answer2.isNotEmpty &&
          answer3.isNotEmpty &&
          answer4.isNotEmpty) {
        finalAnswerGroups.add(group);
      } else if (answer1.isNotEmpty ||
          answer2.isNotEmpty ||
          answer3.isNotEmpty ||
          answer4.isNotEmpty) {
        List<String> existingWords = [];
        if (answer1.isNotEmpty) existingWords.add(answer1);
        if (answer2.isNotEmpty) existingWords.add(answer2);
        if (answer3.isNotEmpty) existingWords.add(answer3);
        if (answer4.isNotEmpty) existingWords.add(answer4);

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
            AnswerGroup completeGroup = AnswerGroup(
              Answer(capitalizeWord(allWords[0]), "", ""),
              Answer(capitalizeWord(allWords[1]), "", ""),
              Answer(capitalizeWord(allWords[2]), "", ""),
              Answer(capitalizeWord(allWords[3]), "", ""),
            );
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
          _originalTextValues['group_${i}_answer_1'] = group.answer1.answer;
          _originalTextValues['group_${i}_answer_2'] = group.answer2.answer;
          _originalTextValues['group_${i}_answer_3'] = group.answer3.answer;
          _originalTextValues['group_${i}_answer_4'] = group.answer4.answer;
        }

        setState(() {
          answerGroups = finalAnswerGroups;
          isLoading = false;
          hasUnsavedChanges = false;
        });

        for (int i = 0; i < finalAnswerGroups.length; i++) {
          var group = finalAnswerGroups[i];
          _updateControllerWithoutListener(i, 1, group.answer1.answer);
          _updateControllerWithoutListener(i, 2, group.answer2.answer);
          _updateControllerWithoutListener(i, 3, group.answer3.answer);
          _updateControllerWithoutListener(i, 4, group.answer4.answer);
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
        switch (answerIndex) {
          case 1:
            initialValue = group.answer1.answer;
          case 2:
            initialValue = group.answer2.answer;
          case 3:
            initialValue = group.answer3.answer;
          case 4:
            initialValue = group.answer4.answer;
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
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hearbat/widgets/edit_custom_module.dart';
import 'package:hearbat/widgets/path/difficulty_selection_widget.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearbat/utils/custom_util.dart';
import 'package:hearbat/utils/user_module_util.dart';
import "../../../widgets/custom_module_card_widget.dart";

class CustomPath extends StatefulWidget {
  @override
  CustomPathState createState() => CustomPathState();
}

class CustomPathState extends State<CustomPath> {
  List<String> moduleNames = [];
  String? _voiceType;

  @override
  void initState() {
    super.initState();
    _loadModules();
    _loadVoiceType();
  }

  void _loadModules() async {
    var modules = await UserModuleUtil.getAllCustomModules();
    if (!mounted) return;
    setState(() {
      moduleNames = modules.keys.toList();
    });
  }

  void _loadVoiceType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceType = prefs.getString('voicePreference') ??
          "en-US-Studio-O"; // Default voice type
    });
  }

  void _addModuleAndPop(String moduleName) async {
    await UserModuleUtil.getAllCustomModules();
    if (!mounted) return;
    _loadModules();
    Navigator.of(context).pop();
  }

  void _navigateToCreateModule() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomUtil(onModuleSaved: _addModuleAndPop)),
    );
  }

  void _deleteModule(String moduleName) async {
    await UserModuleUtil.deleteCustomModule(moduleName);
    if (!mounted) return;

    setState(() {
      moduleNames.remove(moduleName);
    });

    _loadModules();
  }

  void _showModule(String moduleName) async {
    var modules = await UserModuleUtil.getAllCustomModules();
    if (!mounted) return;
    var answerGroups = modules[moduleName] ?? [];

    if (_voiceType != null) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => DifficultySelectionWidget(
            moduleName: moduleName,
            answerGroups: answerGroups,
            voiceType: _voiceType!,
            isWord: true,
            displayDifficulty: false,
            displayVoice: true,
          ),
          fullscreenDialog: true,
        ),
      );
    } else {
      print("Voice type is not loaded yet");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: "Custom Modules",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                child: DottedBorder(
                  dashPattern: [6, 6],
                  borderType: BorderType.RRect,
                  radius: Radius.circular(8),
                  color: Color.fromARGB(255, 35, 102, 29),
                  strokeWidth: 2,
                  child: ElevatedButton(
                      onPressed: _navigateToCreateModule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 94, 224, 82),
                        padding: EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: TextStyle(fontSize: 24.0),
                        minimumSize: Size(double.infinity, 40),
                      ),
                      child: Text("Create New Module",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)))),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: moduleNames.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 8 / 10,
                ),
                itemBuilder: (context, index) {
                  String moduleName = moduleNames[index];
                  return CustomModuleCard(
                    moduleName: moduleName,
                    onStart: () => _showModule(moduleName),
                    onDelete: () => _deleteModule(moduleName),
                    onEdit: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => EditModuleScreen(
                                moduleName: moduleName,
                                onModuleDeleted: () =>
                                    _deleteModule(moduleName),
                              ),
                            ),
                          )
                          .then((_) => _loadModules());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

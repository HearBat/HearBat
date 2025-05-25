import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import '../../utils/translations.dart';

class AnimatedButton extends StatefulWidget {
  // final String chapterName;
  final String moduleName;
  final List<dynamic> answerGroups;
  final Function(String moduleName, List<dynamic> answerGroups) onButtonPressed;

  AnimatedButton({
    super.key,
    required this.moduleName,
    required this.answerGroups,
    required this.onButtonPressed,
  });

  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<EdgeInsets> _buttonMarginAnimation;
  late Animation<double> _shadowOffsetAnimation;
  Color _buttonColor = const Color.fromARGB(255, 241, 223, 254);

@override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 20),
      vsync: this,
    );

    _buttonMarginAnimation = Tween<EdgeInsets>(
      begin: EdgeInsets.only(top: 0),
      end: EdgeInsets.only(top: 8),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _shadowOffsetAnimation = Tween<double>(
      begin: 8.0,  
      end: 8.0,    
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse().then((_) async {
      setState(() {
        _buttonColor = Color.fromARGB(255, 98, 81, 162);
      });

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocale.animatedButtonWidgetExercise.getString(context)),
            content: Text('${AppLocale.animatedButtonWidgetChapterName.getString(context)} ${widget.moduleName}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _buttonColor = const Color.fromARGB(255, 241, 223, 254);
                  });
                },
                child: Text(AppLocale.animatedButtonWidgetCancel.getString(context)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.answerGroups
                      .every((element) => element is String)) {
                    widget.onButtonPressed(
                        widget.moduleName, widget.answerGroups.cast<String>());
                  } else if (widget.answerGroups
                      .every((element) => element is AnswerGroup)) {
                    widget.onButtonPressed(widget.moduleName,
                        widget.answerGroups.cast<AnswerGroup>());
                  }
                  setState(() {
                    _buttonColor = const Color.fromARGB(255, 241, 223, 254);
                  });
                },
                child: Text(AppLocale.animatedButtonWidgetStart.getString(context)),
              ),
            ],
          );
        },
      ).then((_) {
        // reset button color
        setState(() {
          _buttonColor = Color.fromARGB(255, 241, 223, 254);
        });
      });
    });
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

@override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: _shadowOffsetAnimation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 50 * 1.2,
                width: 100 * 1.2,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(100 * 1.5, 50 * 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: _buttonMarginAnimation.value,
              alignment: Alignment.center,
              height: 50 * 1.2,
              width: 100 * 1.2,
              decoration: BoxDecoration(
                color: _buttonColor,
                borderRadius:
                    BorderRadius.all(Radius.elliptical(100 * 1.5, 50 * 1.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
              ),
            ),
          ],
        );
      },
    );
  }
}
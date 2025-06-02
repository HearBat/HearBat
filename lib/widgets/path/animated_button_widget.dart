import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';
import '../../utils/translations.dart';

class AnimatedButton extends StatefulWidget {
  final String moduleName;
  final String? moduleDescription;
  final List<dynamic> answerGroups;
  final void Function(String moduleName, List<dynamic> answerGroups)
      onButtonPressed;

  const AnimatedButton({
    super.key,
    required this.moduleName,
    required this.answerGroups,
    this.moduleDescription,
    required this.onButtonPressed,
  });

  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  late AnimationController _overlayController;
  late Animation<double> _overlayScale;

  bool _pressed = false;

  static const Color _defaultColor = Color(0xFFF1DEFE);
  static const Color _pressedColor = Color(0xFF6251A2);
  static const Color _overlayColor = Color(0xFF9a6bbb);

  Color _buttonColor = _defaultColor;

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _overlayScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  void _onTapUp(TapUpDetails details) async {
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() => _pressed = false);

    setState(() => _buttonColor = _defaultColor);

    await Scrollable.ensureVisible(
      _buttonKey.currentContext!,
      duration: const Duration(milliseconds: 200),
      alignment: 0.5,
    );

    _toggleOverlay();
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayController.reverse().then((_) {
        _overlayEntry!.remove();
        _overlayEntry = null;
        setState(() => _buttonColor = _defaultColor);
      });
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final rb = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final tl = rb.localToGlobal(Offset.zero);
    final sz = rb.size;
    final centerX = tl.dx + sz.width / 2;

    const popOverW = 180.0;
    const arrowW = 20.0;

    final popLeft = centerX - popOverW / 2;
    final arrowLeft = centerX - arrowW / 2;
    final popTop = tl.dy + sz.height + 40;
    final arrowTop = popTop - 10; // or wherever you like

    _overlayEntry = OverlayEntry(builder: (_) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // 1) barrier
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleOverlay,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2) animated pop-over & arrow
          AnimatedBuilder(
            animation: _overlayController,
            builder: (_, child) {
              return Opacity(
                opacity: _overlayController.value,
                child: Transform.scale(
                  scale: _overlayScale.value,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: popLeft,
                  top: popTop,
                  child: _buildPopOver(),
                ),
                Positioned(
                  left: arrowLeft,
                  top: arrowTop,
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 12,
                    child: CustomPaint(
                      size: const Size(arrowW, 10),
                      painter: _UpArrowPainter(color: _overlayColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });

    // this makes it have a high z index , like to the front
    Overlay.of(context).insert(_overlayEntry!);
    _overlayController.forward();
  }

  Widget _buildPopOver() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: _overlayColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.moduleName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.moduleDescription?.isNotEmpty == true
                  ? widget.moduleDescription!
                  : 'Quick training for listening practice.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            // START button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _toggleOverlay();
                  final args = widget.answerGroups.every((e) => e is String)
                      ? widget.answerGroups.cast<String>()
                      : widget.answerGroups.cast<AnswerGroup>();
                  widget.onButtonPressed(widget.moduleName, args);
                },
                child: Text(
                  AppLocale.animatedButtonWidgetStart
                      .getString(context)
                      .toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 100 * 1.2;
    final buttonHeight = (60 * 1.2) + 9;

    return GestureDetector(
      key: _buttonKey,
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1) shadow layer
            Positioned(
              top: _pressed ? 8 : 9,
              left: 0,
              right: 0,
              child: Container(
                height: 60 * 1.2,
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: _pressedColor,
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(120, 75),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // 2) animated button face
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: EdgeInsets.only(top: _pressed ? 8 : 0),
              height: 60 * 1.2,
              width: buttonWidth,
              decoration: BoxDecoration(
                color: _buttonColor,
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(120, 75),
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpArrowPainter extends CustomPainter {
  final Color color;
  _UpArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

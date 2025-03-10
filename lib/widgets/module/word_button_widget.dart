import 'package:flutter/material.dart';
import 'package:hearbat/models/chapter_model.dart';

class WordButton extends StatelessWidget {
  final Answer word;
  final bool isWord;
  final Answer? selectedWord;
  final ValueChanged<Answer> onSelected;

  const WordButton({
    super.key,
    required this.word,
    required this.isWord,
    required this.selectedWord,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onSelected(word),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedWord == word ? Colors.grey : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
        shadowColor: Colors.grey[900],
      ),
      child: isWord ? _textWidget() : _imageWidget(),
    );
  }

  Widget _textWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
          // borrerRadius: BorderRadius.circular(8)
          ),
      child: Text(
        word.answer,
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _imageWidget() {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          word.image!,
          fit: BoxFit.contain,
        ));
  }
}

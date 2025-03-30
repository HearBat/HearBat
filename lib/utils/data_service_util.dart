import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chapter_model.dart';
import '../models/speech_chapter_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();

  factory DataService() {
    return _instance;
  }

  DataService._internal();

  Map<String, Chapter> _soundChapters = {};
  Map<String, Chapter> _wordChapters = {};
  Map<String, SpeechChapter> _speechChapters = {};

  Future<void> loadJson() async {
    try {
      if (_soundChapters.isEmpty) {
        String jsonString = await rootBundle.loadString(
            'assets/data/sound_modules_data.json');
        Map<String, dynamic> jsonData = json.decode(jsonString);
        _soundChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: Chapter
              .fromJson(chapter)
        };
      }

      if (_wordChapters.isEmpty) {
        String jsonString = await rootBundle.loadString(
            'assets/data/word_modules_data.json');
        Map<String, dynamic> jsonData = json.decode(jsonString);
        _wordChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: Chapter
              .fromJson(chapter)
        };
      }

      if (_speechChapters.isEmpty) {
        String jsonString = await rootBundle.loadString(
            'assets/data/speech_modules_data.json');
        Map<String, dynamic> jsonData = json.decode(jsonString);
        _speechChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: SpeechChapter
              .fromJson(chapter)
        };
      }

    } catch (e) {
      print('Error decoding JSON data: $e');
    }
  }

  Chapter getSoundChapter(String chapter) => _soundChapters[chapter] ?? Chapter.empty();
  Chapter getWordChapter(String chapter) => _wordChapters[chapter] ?? Chapter.empty();
  SpeechChapter getSpeechChapter(String chapter) => _speechChapters[chapter] ?? SpeechChapter.empty();

}
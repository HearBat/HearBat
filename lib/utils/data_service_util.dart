import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:hearbat/main.dart';
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
  Map<String, Chapter> _musicChapters = {};
  String? _currentLanguage;

  Future<void> loadJson() async {
    loadJsonLanguageSpecific();
  }

  Future<void> loadJsonLanguageSpecific() async {
    Locale? locale = localization.currentLocale;
    String? languageCode = locale?.languageCode;

    if (languageCode != 'en' && languageCode != 'vi') {
      languageCode = 'en';
    }

    if (languageCode != _currentLanguage) {
      try {
        String jsonString = await rootBundle.loadString(
            'assets/data/${languageCode}_word_modules_data.json');
        Map<String, dynamic> jsonData = json.decode(jsonString);
        _wordChapters.clear();
        _wordChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: Chapter
              .fromJson(chapter)
        };

        jsonString = await rootBundle.loadString(
            'assets/data/${languageCode}_sound_modules_data.json');
        jsonData = json.decode(jsonString);
        _soundChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: Chapter
              .fromJson(chapter)
        };

        jsonString = await rootBundle.loadString(
            'assets/data/${languageCode}_speech_modules_data.json');
        jsonData = json.decode(jsonString);
        _speechChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: SpeechChapter
              .fromJson(chapter)
        };

        jsonString = await rootBundle.loadString(
            'assets/data/${languageCode}_music_pitch_modules_data.json');
        jsonData = json.decode(jsonString);
        _musicChapters = {
          for (var chapter in jsonData['chapters']) chapter['name']: Chapter
              .fromJson(chapter)
        };

        _currentLanguage = languageCode;

      } catch (e) {
        print('Error decoding JSON data: $e');
        _currentLanguage = null;
      }
    }
  }

  List<Map<String, String>> getSoundChapters() => getChapterDisplays(_soundChapters);
  List<Map<String, String>> getWordChapters() => getChapterDisplays(_wordChapters);
  List<Map<String, String>> getMusicChapters() => getChapterDisplays(_musicChapters);
  List<Map<String, String>> getChapterDisplays(Map<String, Chapter> collection) => collection.values.map((chapter) {
    return {
      'name': chapter.name,
      'image': chapter.image,
    };
  }).toList();

  List<Map<String, String>> getSpeechChapters() => _speechChapters.values.map((chapter) {
    return {
      'name': chapter.name,
      'image': chapter.image,
    };
  }).toList();


  Chapter getSoundChapter(String chapter) => _soundChapters[chapter] ?? Chapter.empty();
  Chapter getWordChapter(String chapter) => _wordChapters[chapter] ?? Chapter.empty();
  Chapter getMusicChapter(String chapter) => _musicChapters[chapter] ?? Chapter.empty();
  SpeechChapter getSpeechChapter(String chapter) => _speechChapters[chapter] ?? SpeechChapter.empty();

}
class SpeechModule {
  final List<String> speechGroups;
  SpeechModule(this.speechGroups);

  static SpeechModule fromJson(Map<String, dynamic> json) {
    return SpeechModule(
        [for (var item in json['speechGroups']) item.toString()]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speechGroups': speechGroups.map((group) => group).toList(),
    };
  }
}

class SpeechChapter {
  final Map<String, SpeechModule> speechModules;
  SpeechChapter(this.speechModules);

  static final SpeechChapter _empty = SpeechChapter({});

  factory SpeechChapter.empty() {
    return _empty;
  }

  static SpeechChapter fromJson(Map<String, dynamic> json) {
    return SpeechChapter(
        {for (var module in json['modules']) module['name'] : SpeechModule.fromJson(module)}
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modules': speechModules.map((id, module) => MapEntry(id, module.toJson()))
    };
  }
}
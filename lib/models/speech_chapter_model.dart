class SpeechModule {
  final String name;
  final List<String> speechGroups;
  SpeechModule(this.name, this.speechGroups);

  static SpeechModule fromJson(Map<String, dynamic> json) {
    return SpeechModule(
        json['name'],
        [for (var item in json['speechGroups']) item.toString()]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'speechGroups': speechGroups.map((group) => group).toList(),
    };
  }
}

class SpeechChapter {
  final String name;
  final Map<String, SpeechModule> speechModules;
  SpeechChapter(this.name, this.speechModules);

  static final SpeechChapter _empty = SpeechChapter("", {});

  factory SpeechChapter.empty() {
    return _empty;
  }

  static SpeechChapter fromJson(Map<String, dynamic> json) {
    return SpeechChapter(
        json['name'],
        {for (var module in json['modules']) module['name'] : SpeechModule.fromJson(module)}
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'modules': speechModules.map((name, module) => MapEntry(name, module.toJson()))
    };
  }
}
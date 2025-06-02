class SpeechModule {
  final String name;
  final String? description;
  final List<String> speechGroups;
  SpeechModule(this.name, this.speechGroups, {this.description});

  static SpeechModule fromJson(Map<String, dynamic> json) {
    return SpeechModule(
        json['name'],
        [for (var item in json['speechGroups']) item.toString()],
        description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'speechGroups': speechGroups.map((group) => group).toList(),
    };
  }
}

class SpeechChapter {
  final String name;
  final String image;
  final Map<String, SpeechModule> speechModules;
  SpeechChapter(this.name, this.image, this.speechModules);

  static final SpeechChapter _empty = SpeechChapter("", "", {});

  factory SpeechChapter.empty() {
    return _empty;
  }

  static SpeechChapter fromJson(Map<String, dynamic> json) {
    return SpeechChapter(
        json['name'],
        json['image'],
        {for (var module in json['modules']) module['name'] : SpeechModule.fromJson(module)}
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'modules': speechModules.map((name, module) => MapEntry(name, module.toJson()))
    };
  }
}
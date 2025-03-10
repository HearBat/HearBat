import 'dart:math';

class Answer {
  final String answer;
  final String? path;
  final String? image;

  Answer(this.answer, this.path, this.image);

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'path': path,
      'image': image,
    };
  }

  static Answer fromJson(Map<String, dynamic> json) {
    return Answer(
      json['answer'] as String,
      json['path'] as String?,
      json['image'] as String?,
    );
  }
}

class AnswerGroup {
  final Answer answer1;
  final Answer answer2;
  final Answer answer3;
  final Answer answer4;

  AnswerGroup(this.answer1, this.answer2, this.answer3, this.answer4);

  Map<String, dynamic> toJson() {
    return {
      'answers': [answer1.toJson(), answer2.toJson(), answer3.toJson(), answer4.toJson()]
    };
  }

  static AnswerGroup fromJson(Map<String, dynamic> json) {
    return AnswerGroup(
      Answer.fromJson(json['answers'][0] as Map<String, dynamic>),
      Answer.fromJson(json['answers'][1] as Map<String, dynamic>),
      Answer.fromJson(json['answers'][2] as Map<String, dynamic>),
      Answer.fromJson(json['answers'][3] as Map<String, dynamic>),
    );
  }

  Answer getRandomAnswer(AnswerGroup currentGroup) {
    Random random = Random();
    int number = random.nextInt(4);

    switch (number) {
      case 0:
        return currentGroup.answer1;
      case 1:
        return currentGroup.answer2;
      case 2:
        return currentGroup.answer3;
      case 3:
        return currentGroup.answer4;
      default:
        return currentGroup.answer1;
    }
  }
}

class Module {
  final String name;
  final List<AnswerGroup> answerGroups;
  Module(this.name, this.answerGroups);

  static Module fromJson(Map<String, dynamic> json) {
    return Module(
        json['name'],
        (json['answerGroups'] as List<dynamic>).map((item) => AnswerGroup.fromJson(item as Map<String, dynamic>)).toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'answerGroups': answerGroups.map((group) => group.toJson()).toList(),
    };
  }
}

class Chapter {
  final String name;
  final Map<String, Module> modules;
  Chapter(this.name, this.modules);

  static final Chapter _empty = Chapter("", {});

  factory Chapter.empty() {
    return _empty;
  }
  static Chapter fromJson(Map<String, dynamic> json) {
    return Chapter(
        json['name'],
        //json['modules'].map((module) => MapEntry(module['name'], Module.fromJson(module)))
        { for (Map<String, dynamic> module in (json['modules'] as List<dynamic>)) module['name'] : Module.fromJson(module) }
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'modules': modules.map((name, module) => MapEntry(name, module.toJson())),
    };
  }
}
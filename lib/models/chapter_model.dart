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
  final List<Answer> answers;

  AnswerGroup(this.answers);

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  static AnswerGroup fromJson(Map<String, dynamic> json) {
    var answerList = json['answers'] as List<dynamic>;
    return AnswerGroup(
      answerList.map((answer) => Answer.fromJson(answer)).toList(),
    );
  }

  Answer getRandomAnswer(AnswerGroup currentGroup) {
    Random random = Random();
    int index = random.nextInt(answers.length);
    return answers[index];
  }
}

class Module {
  final String name;
  final String? description;
  final List<AnswerGroup> answerGroups;

  Module(this.name, this.answerGroups, {this.description});

  static Module fromJson(Map<String, dynamic> json) {
    return Module(
      json['name'],
      (json['answerGroups'] as List<dynamic>)
          .map((item) => AnswerGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'answerGroups': answerGroups.map((group) => group.toJson()).toList(),
    };
  }
}

class Chapter {
  final String name;
  final String image;
  final Map<String, Module> modules;
  Chapter(this.name, this.image, this.modules);

  static final Chapter _empty = Chapter("", "", {});

  factory Chapter.empty() {
    return _empty;
  }
  static Chapter fromJson(Map<String, dynamic> json) {
    return Chapter(
        json['name'],
        json['image'],
        { for (Map<String, dynamic> module in (json['modules'] as List<dynamic>)) module['name'] : Module.fromJson(module) }
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'modules': modules.map((name, module) => MapEntry(name, module.toJson())),
    };
  }
}
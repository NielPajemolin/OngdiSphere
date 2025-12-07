import 'task.dart';

class Subject {
  String id;
  String name;
  List<Task> tasks;

  Subject({
    required this.id,
    required this.name,
    this.tasks = const [],
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        name: json['name'],
        tasks: json['tasks'] != null
            ? List<Task>.from(json['tasks'].map((x) => Task.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tasks': tasks.map((x) => x.toJson()).toList(),
      };
}

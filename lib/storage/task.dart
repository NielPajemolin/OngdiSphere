class Task {
  String id;
  String title;
  String subjectId;
  String subjectName;
  DateTime dateTime;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.dateTime,
    this.done = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subjectId: json['subjectId'] ?? '',
        subjectName: json['subjectName'] ?? '',
        dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
        done: json['done'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'dateTime': dateTime.toIso8601String(),
        'done': done,
      };
}

class Exam {
  String id;
  String title;
  String subjectId;
  String subjectName;
  DateTime dateTime;
  bool done;

  Exam({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.dateTime,
    this.done = false,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id'],
        title: json['title'],
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        dateTime: DateTime.parse(json['dateTime']),
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

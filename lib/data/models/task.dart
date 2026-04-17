class Task {
  String id;
  String title;
  String subjectId;
  String subjectName;
  DateTime dateTime;
  int? reminderMinutes;
  bool done;
  bool? wasLate;

  Task({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.dateTime,
    this.reminderMinutes,
    this.done = false,
    this.wasLate,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subjectId: json['subjectId'] ?? '',
        subjectName: json['subjectName'] ?? '',
        dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
        reminderMinutes: (json['reminderMinutes'] as num?)?.toInt(),
        done: json['done'] ?? false,
        wasLate: json['wasLate'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'dateTime': dateTime.toIso8601String(),
        if (reminderMinutes != null) 'reminderMinutes': reminderMinutes,
        'done': done,
        if (wasLate != null) 'wasLate': wasLate,
      };
}

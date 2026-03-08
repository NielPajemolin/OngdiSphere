import 'package:isar/isar.dart';

part 'isar_exam.g.dart';

@collection
class IsarExam {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String uuid;
  
  @Index()
  late String userId;
  
  late String title;
  
  @Index()
  late String subjectId;
  late String subjectName;
  late DateTime dateTime;
  late bool done;
}

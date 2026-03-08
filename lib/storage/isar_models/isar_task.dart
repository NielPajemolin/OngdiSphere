import 'package:isar/isar.dart';
import 'isar_subject.dart';

part 'isar_task.g.dart';

@collection
class IsarTask {
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
  
  final subject = IsarLink<IsarSubject>();
}

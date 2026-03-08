import 'package:isar/isar.dart';
import 'isar_task.dart';

part 'isar_subject.g.dart';

@collection
class IsarSubject {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String uuid;
  
  @Index()
  late String userId;
  
  late String name;
  
  @Backlink(to: 'subject')
  final tasks = IsarLinks<IsarTask>();
}

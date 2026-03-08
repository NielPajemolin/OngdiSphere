import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'isar_models/isar_subject.dart';
import 'isar_models/isar_task.dart';
import 'isar_models/isar_exam.dart';

class IsarDatabaseService {
  static late Isar _isar;

  static final IsarDatabaseService _instance = IsarDatabaseService._internal();

  factory IsarDatabaseService() {
    return _instance;
  }

  IsarDatabaseService._internal();

  /// Initialize the Isar database
  static Future<Isar> initialize() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [IsarSubjectSchema, IsarTaskSchema, IsarExamSchema],
        directory: dir.path,
      );
    } else {
      _isar = Isar.getInstance()!;
    }
    return _isar;
  }

  /// Get the Isar instance
  static Isar getInstance() {
    if (Isar.instanceNames.isEmpty) {
      throw Exception('Isar not initialized');
    }
    return Isar.getInstance()!;
  }

  /// Close the database
  static Future<void> close() async {
    await _isar.close();
  }
}

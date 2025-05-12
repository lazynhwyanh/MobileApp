import 'n1_exercises.dart';
import 'n2_exercises.dart';
import 'n3_exercises.dart';
import 'n4_exercises.dart';
import 'n5_exercises.dart';

List<Map<String, String>> loadExercisesByLevel(String level) {
  switch (level) {
    case 'N1':
      return n1Exercises;
    case 'N2':
      return n2Exercises;
    case 'N3':
      return n3Exercises;
    case 'N4':
      return n4Exercises;
    case 'N5':
      return n5Exercises;
    default:
      return [];
  }
}

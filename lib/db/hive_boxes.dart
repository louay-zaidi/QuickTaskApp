import 'package:hive/hive.dart';
import '../models/task.dart'; 

class HiveBoxes {
  static Box<Task> getTasksBox() => Hive.box<Task>('tasks');
}
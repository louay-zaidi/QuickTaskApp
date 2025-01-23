import 'package:hive/hive.dart';
import 'package:quick_tasks/models/task.dart';

class TaskService {
  static const String taskBoxName = 'tasks';

  // Open the box
  static Future<Box<Task>> openBox() async {
    return await Hive.openBox<Task>(taskBoxName);
  }

  // Add a task
  static Future<void> addTask(Task task) async {
    final box = await openBox();
    await box.add(task);
  }

  // Retrieve all tasks
  static Future<List<Task>> getTasks() async {
    final box = await openBox();
    return box.values.toList();
  }

 // Update a task's status
static Future<void> updateTaskStatus(int index) async {
  final box = await openBox();
  final task = box.getAt(index);
  
  if (task != null) {
    // Call the checkStatus method to automatically update the task status
    task.checkStatus();

    // Update task in the box
    await box.putAt(index, task);  
  }
}


  // Update a task
  static Future<void> updateTask(int index, Task task) async {
    final box = await openBox();
    await box.putAt(index, task);
  }

  // Delete a task
  static Future<void> deleteTask(int index) async {
    final box = await openBox();
    await box.deleteAt(index);
  }
}

import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; 

part 'task.g.dart'; 

enum TaskStatus {
  inProgress,
  completed,
  missed,
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String time;

  @HiveField(4)
  late TaskStatus status;

  Task({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
  });

  // Method to check if the task is overdue and update its status to 'missed'
  void checkStatus() {
    final currentDateTime = DateTime.now();
    final taskDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$date $time');
    
    // If the task's time has passed and it's not completed, set the status to 'missed'
    if (taskDateTime.isBefore(currentDateTime) && status != TaskStatus.completed) {
      status = TaskStatus.missed;
    }
  }
}

// register the adapter
@HiveType(typeId: 1)
class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final typeId = 1;

  @override
  TaskStatus read(BinaryReader reader) {
    final index = reader.readInt();
    return TaskStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeInt(obj.index);
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/task.dart'; 
import '../services/TaskService.dart';
import 'package:quick_tasks/l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? selectedChip;
  List<Task> displayedTasks = [];
  List<Task> progressTasks = [];
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    _initializeHiveData();
  }

  Future<void> _initializeHiveData() async {
    // Open the Hive box
    taskBox = await Hive.openBox<Task>('tasks');

    // Get all tasks from the Hive box
    final allTasks = taskBox.values.toList();

    // Console log to check the tasks in the box
    print("All tasks from Hive: ${allTasks.length}");
    allTasks.forEach((task) {
      print("Task: ${task.title}, Date: ${task.date}, Status: ${task.status}");
    });

    // Get today's date in the same format as the saved task (yyyy-MM-dd)
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Loop through all tasks and update their status
    for (int i = 0; i < allTasks.length; i++) {
      final task = allTasks[i];
      await TaskService.updateTaskStatus(i); // Update the task status
    }

    // Filter tasks for today's date
    displayedTasks = allTasks.where((task) => task.date == today).toList();

    // Console log to check filtered tasks
    print("Displayed tasks for today: ${displayedTasks.length}");
    displayedTasks.forEach((task) {
      print(
          "Displayed Task: ${task.title}, Date: ${task.date}, Status: ${task.status}");
    });

    // Sort displayedTasks by time
    displayedTasks.sort((a, b) {
      DateTime aDateTime =
          DateFormat('yyyy-MM-dd HH:mm').parse('${a.date} ${a.time}');
      DateTime bDateTime =
          DateFormat('yyyy-MM-dd HH:mm').parse('${b.date} ${b.time}');
      return aDateTime.compareTo(bDateTime);
    });

    // Initialize the progressTasks to show all tasks for today
    progressTasks = allTasks.where((task) => task.date == today).toList();

    // Console log to check progress tasks
    print("Progress tasks for today: ${progressTasks.length}");
    progressTasks.forEach((task) {
      print(
          "Progress Task: ${task.title}, Date: ${task.date}, Status: ${task.status}");
    });

    setState(() {});
  }

  // Filter tasks based on selected status
  void _filterTasks(String key) {
    setState(() {
      selectedChip = key;
      final allTasks = taskBox.values.toList(); // Get tasks from the Hive box
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (key == 'myTasks') {
        displayedTasks = allTasks.where((task) => task.date == today).toList();
      } else if (key == 'inProgress') {
        displayedTasks = allTasks
            .where((task) =>
                task.status == TaskStatus.inProgress && task.date == today)
            .toList();
      } else if (key == 'completed') {
        displayedTasks = allTasks
            .where((task) =>
                task.status == TaskStatus.completed && task.date == today)
            .toList();
      } else if (key == 'missed') {
        displayedTasks = allTasks
            .where((task) =>
                task.status == TaskStatus.missed && task.date == today)
            .toList();
      }

      // Sort tasks after filtering
      displayedTasks.sort((a, b) {
        DateTime aDateTime =
            DateFormat('yyyy-MM-dd HH:mm').parse('${a.date} ${a.time}');
        DateTime bDateTime =
            DateFormat('yyyy-MM-dd HH:mm').parse('${b.date} ${b.time}');
        return aDateTime.compareTo(bDateTime);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  AppLocalizations.of(context)?.translate('greeting') ??
                      "Hello!",
                  style: const TextStyle(
                    fontSize: 24.97,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  AppLocalizations.of(context)?.translate('greetingComment') ??
                      "Have a nice day.",
                  style: const TextStyle(
                    fontSize: 12.49,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        AppLocalizations.of(context)?.translate('MyTasks') ??
                            "My Tasks",
                        'myTasks', 
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        AppLocalizations.of(context)?.translate('InProgress') ??
                            "In-Progress",
                        'inProgress', 
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        AppLocalizations.of(context)?.translate('Completed') ??
                            "Completed",
                        'completed', 
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        AppLocalizations.of(context)?.translate('Missed') ??
                            "Missed",
                        'missed',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  scrollDirection: Axis.horizontal,
                  children: displayedTasks.isEmpty
                      ? [
                          Center(
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.translate('NothingHere') ??
                                  "Nothing Here! 🤔",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ]
                      : displayedTasks.map((task) {
                          return _buildTaskCard(
                            task.title,
                            task.description,
                            task.date,
                            task.time,
                            task.status,
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  AppLocalizations.of(context)?.translate('DailyProgress') ??
                      "Daily Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: progressTasks.map((task) {
                  return _buildProgressCard(
                    task.title,
                    "${task.description}",
                    task.time,
                    task.status,
                    task,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, String key) {
    bool isSelected = selectedChip == key; 
    return GestureDetector(
      onTap: () {
        _filterTasks(key);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFc3f44d),
          borderRadius: BorderRadius.circular(40.57),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String description, String date,
      String time, TaskStatus status) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: status == TaskStatus.inProgress
              ? const Color(0XFFebfaef)
              : (status == TaskStatus.completed
                  ? const Color(0XFFe5def6)
                  : const Color(0XFFfaf3eb)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  status == TaskStatus.inProgress
                      ? "In Progress"
                      : (status == TaskStatus.completed
                          ? "Completed"
                          : "Missed"),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xff1a434e)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title.length > 30 ? '${title.substring(0, 30)}...' : title,
              style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xff4B434e),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description.length > 10 
                  ? '${description.substring(0, 10)}...'
                  : description,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff5d5e61),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String subtitle, String taskTime,
      TaskStatus status, Task task) {
    IconData statusIcon;
    Color statusColor;

  
    switch (status) {
      case TaskStatus.completed:
        statusIcon = Icons.check_circle;
        statusColor = Colors.white;
        break;
      case TaskStatus.inProgress:
        statusIcon = Icons.timelapse;
        statusColor = Colors.white;
        break;
      case TaskStatus.missed:
        statusIcon = Icons.error;
        statusColor = Colors.white;
        break;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: const Color(0xFF325863),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          radius: 24,
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4), 
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  taskTime, 
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {
            _changeTaskStatus(task);
          },
        ),
        onLongPress: () {
          _showDeleteConfirmationDialog(task);
        },
      ),
    );
  }

// Function to show delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(Task task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.translate('deleteTaskTitle') ??
                'Delete Task',
          ),
          content: Text(
            AppLocalizations.of(context)?.translate('deleteTaskConfirmation') ??
                'Are you sure you want to delete this task?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.translate('delete') ?? 'Delete',
              ),
              onPressed: () {
                _deleteTask(task); 
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Function to delete the task from the database
  Future<void> _deleteTask(Task task) async {
    await taskBox.delete(task.key); 
    setState(() {
    
      progressTasks.remove(task);
      displayedTasks.remove(task);
    });
  }

// Function to change the task status
  Future<void> _changeTaskStatus(Task task) async {
  
    String newStatus = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true, 
          backgroundColor: Color(0xFF1a434e),
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      AppLocalizations.of(context)
                              ?.translate('ChangeTaskStatus') ??
                          'Change Task Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFc3f44d),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop('inProgress');
                    },
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withOpacity(0.2), 
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.timelapse,
                        color: Colors.white,
                      ),
                    ),
                   title:  Text( AppLocalizations.of(context)
                              ?.translate('InProgress') ??
                          'In-Progress',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const Divider(
                    color: Color(0XFFc3f44d), 
                    thickness: 1.5,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop('completed');
                    },
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withOpacity(0.2), 
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                    title:  Text(AppLocalizations.of(context)
                              ?.translate('Completed') ??
                          'Completed',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const Divider(
                    color: Color(0XFFc3f44d), 
                    thickness: 1.5,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop('missed');
                    },
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withOpacity(0.2), 
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    ),
                     title:  Text(AppLocalizations.of(context)
                              ?.translate('Missed') ??
                          'Missed',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ) ??
        'inProgress'; // Default value

    // Update task status based on selection
    TaskStatus newTaskStatus;
    switch (newStatus) {
      case 'completed':
        newTaskStatus = TaskStatus.completed;
        break;
      case 'missed':
        newTaskStatus = TaskStatus.missed;
        break;
      default:
        newTaskStatus = TaskStatus.inProgress;
    }

    // Update the task's status in Hive
    task.status = newTaskStatus;
    await task.save(); // Save the updated task back to the Hive box

    setState(() {
      // Refresh the list to reflect the updated status
    });
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../services/TaskService.dart';
import '../services/holiday_service.dart';
import 'package:quick_tasks/l10n/app_localizations.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Task>> _selectedTasks;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late List<Task> _tasks;
  Map<DateTime, List<String>> _holidays = {};
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _tasks = [];
    _selectedTasks = ValueNotifier(_getTasksForDay(_selectedDay));

    _loadTasks();
    _fetchHolidays();
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    super.dispose();
  }

  // Load tasks from the database
  Future<void> _loadTasks() async {
    final tasks = await TaskService.getTasks();
    setState(() {
      _tasks = tasks;
      _selectedTasks.value = _getTasksForDay(_selectedDay);
    });
  }

  // Fetch holidays from the API
  Future<void> _fetchHolidays() async {
    try {
      final holidays = await HolidayService.getItalianHolidays();
      setState(() {
        _holidays = holidays;
      });
    } catch (error) {
      print('Failed to fetch holidays: $error');
    }
  }

  // Get tasks for a specific day
  List<Task> _getTasksForDay(DateTime day) {
    final filteredTasks = _tasks.where((task) {
      final taskDate = DateFormat('yyyy-MM-dd').parse(task.date);
      return taskDate.year == day.year &&
          taskDate.month == day.month &&
          taskDate.day == day.day;
    }).toList();

    // Sort tasks by time
    filteredTasks.sort((a, b) {
      final timeA = DateFormat('yyyy-MM-dd HH:mm').parse('${a.date} ${a.time}');
      final timeB = DateFormat('yyyy-MM-dd HH:mm').parse('${b.date} ${b.time}');
      return timeA.compareTo(timeB);
    });

    return filteredTasks;
  }

  // Get holidays for a specific day
  List<String> _getHolidaysForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _holidays[dayKey] ?? [];
  }

  // Display the tasks for the selected day
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedTasks.value = _getTasksForDay(selectedDay);
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
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop('inProgress');
                    },
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.timelapse,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                        AppLocalizations.of(context)?.translate('InProgress') ??
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
                        color: Colors.white.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                        AppLocalizations.of(context)?.translate('Completed') ??
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
                        color: Colors.white.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                        AppLocalizations.of(context)?.translate('Missed') ??
                            'Missed',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ) ??
        'inProgress';

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

    task.status = newTaskStatus;
    await task.save();

    setState(() {});
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onTap: onTap,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF1a434e),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xffc3f44d)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xffc3f44d)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditTaskBottomSheet(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    final dateController = TextEditingController(text: task.date);
    final timeController = TextEditingController(text: task.time);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: const Color(0xFF325863),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFc3f44d),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppLocalizations.of(context)?.translate('EditTaskTitle') ??
                        "Edit Task",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFc3f44d),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: titleController,
                  label:
                      AppLocalizations.of(context)?.translate('Name') ?? "Name",
                  hintText:
                      AppLocalizations.of(context)?.translate('TaskName') ??
                          "TaskName",
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)
                              ?.translate('TaskNameErrorEmpty') ??
                          "Task name cannot be empty."
                      : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: descriptionController,
                  label:
                      AppLocalizations.of(context)?.translate('Description') ??
                          "Description",
                  hintText: AppLocalizations.of(context)
                          ?.translate('TaskDescription') ??
                      "Write a brief description...",
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)
                              ?.translate('TaskDescriptionErrorEmpty') ??
                          "Description cannot be empty."
                      : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: dateController,
                  label:
                      AppLocalizations.of(context)?.translate('Date') ?? "Date",
                  hintText:
                      AppLocalizations.of(context)?.translate('TaskDate') ??
                          "Pick a Date",
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          pickedDate.toIso8601String().split('T')[0];
                    }
                  },
                  readOnly: true,
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)
                              ?.translate('TaskDateErrorEmpty') ??
                          "Please pick a date."
                      : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: timeController,
                  label:
                      AppLocalizations.of(context)?.translate('Time') ?? "Time",
                  hintText:
                      AppLocalizations.of(context)?.translate('TaskTime') ??
                          "Pick a Time",
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      timeController.text = pickedTime.format(context);
                    }
                  },
                  readOnly: true,
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)
                              ?.translate('TaskTimeErrorEmpty') ??
                          "Please pick a time."
                      : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('cancel') ??
                            "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedTask = Task(
                          title: titleController.text,
                          description: descriptionController.text,
                          date: dateController.text,
                          time: timeController.text,
                          status: task.status,
                        );

                        final index = _tasks.indexOf(task);
                        await TaskService.updateTask(index, updatedTask);

                        setState(() {
                          _tasks[index] = updatedTask;
                          _selectedTasks.value = _getTasksForDay(_selectedDay);
                        });

                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFc3f44d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('SaveTask') ??
                            "Save Task",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1a434e),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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
        onTap: () {
          _showEditTaskBottomSheet(context, task);
        },
        onLongPress: () {
          _showDeleteConfirmationDialog(context, task);
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(task);
              },
              child: Text(
                AppLocalizations.of(context)?.translate('delete') ?? 'Delete',
              ),
            ),
          ],
        );
      },
    );
  }

  // Implement the delete functionality
  Future<void> _deleteTask(Task taskToDelete) async {
    await TaskService.deleteTask(_tasks.indexOf(taskToDelete));
    setState(() {
      _tasks.remove(taskToDelete);
      _selectedTasks.value = _getTasksForDay(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(3000, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: (day) => _getTasksForDay(day),
                holidayPredicate: (day) => _getHolidaysForDay(day).isNotEmpty,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF325863),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFd2c2f8),
                    shape: BoxShape.circle,
                  ),
                  holidayDecoration: BoxDecoration(
                    color: Color(0xFFc3f44d),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ValueListenableBuilder<List<Task>>(
              valueListenable: _selectedTasks,
              builder: (context, tasks, _) {
                final holidays = _getHolidaysForDay(_selectedDay);
                final totalItems = holidays.length + tasks.length;

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    if (index < holidays.length) {
                      final holiday = holidays[index];
                      return ListTile(
                        leading:
                            Icon(Icons.celebration, color: Color(0xFFc3f44d)),
                        title: Text(
                          holiday,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Holiday"),
                      );
                    } else {
                      final taskIndex = index - holidays.length;
                      final task = tasks[taskIndex];
                      return _buildProgressCard(
                        task.title,
                        task.description,
                        task.time,
                        task.status,
                        task,
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

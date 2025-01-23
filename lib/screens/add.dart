import 'package:flutter/material.dart';
import '../services/TaskService.dart';
import '../models/task.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:quick_tasks/l10n/app_localizations.dart';


class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TaskStatus _selectedStatus = TaskStatus.inProgress;


  final RegExp _specialCharRegExp = RegExp(r'^[^a-zA-Z0-9\s]+$');

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _addTaskToDatabase() async {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        time: _timeController.text,
        status: _selectedStatus,
      );

      await TaskService.addTask(newTask); // Add task using the service
      print(
          'Task Created: ${newTask.title}, ${newTask.description}, ${newTask.date}, ${newTask.time}, ${newTask.status}');

      // Show the success dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: AppLocalizations.of(context)?.translate('TaskAdded') ??
            "Task Added",
        desc: AppLocalizations.of(context)?.translate('TaskAddedDescription') ??
            "Your task has been added successfully!",
        btnOkOnPress: () {
          // Clear form fields and reset dropdown
          _titleController.clear();
          _descriptionController.clear();
          _dateController.clear();
          _timeController.clear();
          setState(() {
            _selectedStatus = TaskStatus.inProgress;
          });
        },
        btnOkColor: Color(0xFFc3f44d),
      ).show();
    } else {
      print("Form contains errors.");
    }
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

  Widget _buildDropdownField({
    required String label,
    required TaskStatus value,
    required List<TaskStatus> items,
    required Function(TaskStatus?) onChanged,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Color(0xff1a434e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xffc3f44d)),
          ),
          child: DropdownButton<TaskStatus>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            underline: Container(), 
            dropdownColor:
                Color(0xFF1a434e), 

            items: items
                .map(
                  (item) => DropdownMenuItem<TaskStatus>(
                    value: item,
                    child: Text(
                      item.toString().split('.').last,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0, 
            child: Container(
              padding: const EdgeInsets.only(
                  top: 24, left: 24, right: 24, bottom: 0),
              decoration: const BoxDecoration(
                color: Color(0xFF325863),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        130,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            controller: _titleController,
                            label: AppLocalizations.of(context)
                                    ?.translate('Name') ??
                                "Name",
                            hintText: AppLocalizations.of(context)
                                    ?.translate('TaskName') ??
                                "TaskName",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)
                                        ?.translate('TaskNameErrorEmpty') ??
                                    "Task name cannot be empty.";
                              }
                              if (_specialCharRegExp.hasMatch(value.trim())) {
                                return AppLocalizations.of(context)
                                        ?.translate('TaskNameErrorSC') ??
                                    "Task name cannot contain only special characters.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _dateController,
                            label: AppLocalizations.of(context)
                                    ?.translate('Date') ??
                                "Date",
                            hintText: AppLocalizations.of(context)
                                    ?.translate('TaskDate') ??
                                "Pick a Date",
                            onTap: _pickDate,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)
                                        ?.translate('TaskDateErrorEmpty') ??
                                    "Please pick a date.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _timeController,
                            label: AppLocalizations.of(context)
                                    ?.translate('Time') ??
                                "Time",
                            hintText: AppLocalizations.of(context)
                                    ?.translate('TaskTime') ??
                                "Pick a Time",
                            onTap: _pickTime,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)
                                        ?.translate('TaskTimeErrorEmpty') ??
                                    "Please pick a time.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _descriptionController,
                            label: AppLocalizations.of(context)
                                    ?.translate('Description') ??
                                "Description",
                            hintText: AppLocalizations.of(context)
                                    ?.translate('TaskDescription') ??
                                "Write a brief description...",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)?.translate(
                                        'TaskDescriptionErrorEmpty') ??
                                    "Description cannot be empty.";
                              }
                              if (_specialCharRegExp.hasMatch(value.trim())) {
                                return AppLocalizations.of(context)
                                        ?.translate('TaskDescriptionErrorSC') ??
                                    "Description cannot contain only special characters.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildDropdownField(
                            label: AppLocalizations.of(context)
                                    ?.translate('Status') ??
                                "Status",
                            value: _selectedStatus,
                            items: TaskStatus.values,
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: _addTaskToDatabase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFc3f44d),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 24,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)
                                        ?.translate('SaveTask') ??
                                    "Save Task",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1a434e),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

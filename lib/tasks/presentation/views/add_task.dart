import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:timesheet_management/tasks/data/dataSources/task_datasource.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/presentation/providers/auth_provider.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';

import '../providers/history_provider.dart';

class AddTask extends ConsumerStatefulWidget {
  const AddTask({
    Key? key,
    required this.onIntervalSelected,
  }) : super(key: key);
  final Function(String) onIntervalSelected;

  @override
  ConsumerState createState() => _AddTaskState();
}

class _AddTaskState extends ConsumerState<AddTask>
    with SingleTickerProviderStateMixin {
  final TextEditingController _addTaskController = TextEditingController();
  String _selectedInterval = 'DAY';
  late DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // local();
  }

  // void local() {
  //   final taskProviders = ref.read(taskProvider.notifier);
  //   // taskProviders.onTaskListChange = (updatedList) {
  //   //   // React to the updated task list here
  //   // };
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        title: Text(
          AppLocalizations.of(context)!.addTask,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.taskname,
                style: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(width: 1, color: Colors.redAccent.shade700),
                ),
                child: TextField(
                  controller: _addTaskController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Enter A Task',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                iconEnabledColor: Colors.red.shade300,
                value: _selectedInterval,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedInterval = newValue;
                      widget.onIntervalSelected(_selectedInterval);
                      if (_selectedInterval == 'WEEK') {
                        _showDatePicker(context);
                      }
                    });
                  }
                },
                items: <String>['DAY', 'WEEK', 'MONTH']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _submitTask(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.submittask,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 10)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(), // You can customize the theme here
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitTask(BuildContext context) async {
    final newTaskText = _addTaskController.text.trim();
    if (newTaskText.isNotEmpty) {
      final userId = ref.read(currentUserProvider) as int;
      final dbHelper = DatabaseHelper();

      // Check if the task already exists
      final existingTasks = await dbHelper.getAllTasksWithUserId(userId);
      if (existingTasks.any((task) => task.taskName == newTaskText)) {
        Fluttertoast.showToast(
          msg: "Task already exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      final newTask = Tasks(
        id: 0,
        taskName: newTaskText,
        dateTime: _selectedDate,
        interval: _selectedInterval,
      );

      ref.read(taskProvider.notifier).addTask(newTask, userId);
      ref.read(taskHistoryProvider.notifier).addTaskToHistory(newTask, userId);

      Fluttertoast.showToast(
        msg: "Task Added Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 9, 63, 212),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      AnimatedSnackBar.material(
        'Please enter a task before adding',
        type: AnimatedSnackBarType.info,
      ).show(context);
      return;
    }
  }
}

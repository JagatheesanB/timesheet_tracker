import 'dart:async';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/presentation/providers/completed_provider.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';

import '../providers/auth_provider.dart';

class TaskTile extends ConsumerStatefulWidget {
  final Tasks task;
  final Function onComplete;
  final Function(int) onUpdateHours;
  final Function onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onUpdateHours,
    required this.onDelete,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  late Timer _timer;
  int seconds = 0;
  bool isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration.zero, () {});
  }

  void toggleTimer() {
    if (isTimerRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
        if (seconds % 3600 == 0) {
          widget.onUpdateHours(1);
        }
      });
    });
  }

  void pauseTimer() {
    isTimerRunning = false;
    _timer.cancel();
  }

  void _completeTask() {
    pauseTimer();

    final int? userId = ref.read(currentUserProvider);
    ref
        .read(completedTasksprovider.notifier)
        .addCompletedTask(widget.task, seconds, userId!);
    ref.read(taskProvider.notifier).deleteTask(widget.task.id);

    Fluttertoast.showToast(
      msg: '${widget.task.taskName} Completed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = '${(seconds ~/ 3600).toString().padLeft(2, '0')}'
        ':${((seconds ~/ 60) % 60).toString().padLeft(2, '0')}'
        ':${(seconds % 60).toString().padLeft(2, '0')}';

    String firstLetter = widget.task.taskName.isNotEmpty
        ? widget.task.taskName.substring(0, 1).toUpperCase()
        : '';

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: const Color.fromARGB(255, 233, 195, 192),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete_outline_outlined, color: Colors.black),
      ),
      onDismissed: (direction) {
        final taskProviderNotifier = ref.read(taskProvider.notifier);
        taskProviderNotifier.deleteTask(widget.task.id);
        AnimatedSnackBar.material(
          'Task Deleted',
          type: AnimatedSnackBarType.info,
        ).show(context);
        return;
      },
      child: GestureDetector(
        onDoubleTap: () {
          _editTaskName(context);
        },
        child: widget.task.isCompleted
            ? const SizedBox()
            : ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.shade700,
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.task.taskName,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Complete',
                      child: GestureDetector(
                        onTap: _completeTask,
                        child: const Icon(
                          Icons.flag,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {
                        toggleTimer();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                        child: Text(
                          displayTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _editTaskName(BuildContext context) async {
    String editedTaskName = widget.task.taskName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Task Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  editedTaskName = value;
                },
                controller: TextEditingController()
                  ..text = widget.task.taskName,
                decoration: const InputDecoration(
                  hintText: "Enter new task name",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // setState(() {
                ref
                    .read(taskProvider.notifier)
                    .updateTaskName(editedTaskName, widget.task.id);
                // });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

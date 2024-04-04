import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';
import 'package:timesheet_management/tasks/presentation/widgets/tasktile.dart';

class MonthTab extends ConsumerStatefulWidget {
  final Function(Tasks) completeTask;
  final Function(Tasks) deleteTask;
  final List<Tasks> taskList;

  const MonthTab({
    super.key,
    required this.completeTask,
    required this.deleteTask,
    required this.taskList,
  });

  @override
  ConsumerState createState() => MonthTabState();
}

class MonthTabState extends ConsumerState<MonthTab>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasks for the "MONTH" interval
    final taskList = ref.watch(taskProvider);
    final monthTasks =
        taskList.where((task) => task.interval == "MONTH").toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: monthTasks.isEmpty
              ? _buildNoTasksWidget()
              : ListView.builder(
                  itemCount: monthTasks.length,
                  itemBuilder: (context, index) {
                    final task = monthTasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TaskTile(
                        task: task,
                        onComplete: () {
                          widget.completeTask(task);
                        },
                        onUpdateHours: (int hours) {},
                        onDelete: () {
                          setState(() {
                            widget.deleteTask(task);
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoTasksWidget() {
    return const Center(
      child: Text(
        'Add task',
        style: TextStyle(
            fontSize: 20,
            fontFamily: 'poppins',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.normal,
            color: Colors.black),
      ),
    );
  }
}

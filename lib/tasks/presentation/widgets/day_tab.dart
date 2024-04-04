import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';
import 'package:timesheet_management/tasks/presentation/widgets/tasktile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DayPage extends ConsumerStatefulWidget {
  final List<Tasks> taskList;
  final Function(Tasks) completeTask;
  final Function(Tasks) deleteTask;

  const DayPage({
    super.key,
    required this.taskList,
    required this.completeTask,
    required this.deleteTask,
  });

  @override
  ConsumerState createState() => DayPageState();
}

class DayPageState extends ConsumerState<DayPage>
    with TickerProviderStateMixin {
  int totalHours = 0;
  final List<Tasks> newTasks = [];
  late List<Tasks> taskList;

  @override
  void initState() {
    super.initState();
    taskList = widget.taskList;
  }

  @override
  Widget build(BuildContext context) {
    final taskList = ref.watch(taskProvider);
    final dayTasks = taskList.where((task) => task.interval == "DAY").toList();

    return Column(
      children: [
        _buildTaskBar(),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: dayTasks.isEmpty
              ? _buildNoTasksWidget()
              : ListView.builder(
                  itemCount: dayTasks.length,
                  itemBuilder: (context, index) {
                    final task = dayTasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TaskTile(
                        task: task,
                        onComplete: () {
                          widget.completeTask(task);
                        },
                        onDelete: () {
                          widget.deleteTask(task);
                        },
                        onUpdateHours: (int hours) {
                          setState(() {
                            totalHours += hours;
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

  Widget _buildTaskBar() {
    return Row(
      children: [
        const Padding(padding: EdgeInsets.all(16.0)),
        Text(
          AppLocalizations.of(context)!.taskList,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 75)),
        Text(
          '$totalHours hrs/Day',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )
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

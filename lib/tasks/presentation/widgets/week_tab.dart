import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';
import 'package:timesheet_management/tasks/presentation/widgets/tasktile.dart';

class WeekPage extends ConsumerStatefulWidget {
  final List<Tasks> taskList;
  final DateTime selectedDate;
  final Function(Tasks) completeTask;
  final Function(Tasks) deleteTask;

  const WeekPage({
    Key? key,
    required this.selectedDate,
    required this.completeTask,
    required this.deleteTask,
    required this.taskList,
  }) : super(key: key);

  @override
  ConsumerState createState() => WeekPageState();
}

class WeekPageState extends ConsumerState<WeekPage>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  final List<Tasks> newTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final taskList = ref.watch(taskProvider);
    final selectedDateTasks = taskList
        .where((task) =>
            task.interval == "WEEK" &&
            _isSameDay(task.dateTime!, _selectedDate))
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            7,
            (index) {
              final day = _selectedDate
                  .subtract(Duration(days: _selectedDate.weekday - 1))
                  .add(Duration(days: index));
              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                },
                child: Column(
                  children: [
                    Text(DateFormat('E').format(day)),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: (day == _selectedDate) ? Colors.red : null,
                      ),
                    ),
                    if (isToday)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: selectedDateTasks.isEmpty
              ? _buildNoTasksWidget()
              : ListView.builder(
                  itemCount: selectedDateTasks.length,
                  itemBuilder: (context, index) {
                    final task = selectedDateTasks[index];
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
                            newTasks.remove(task);
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildNoTasksWidget() {
    return const Center(
      child: Text(
        'No tasks for this date',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'poppins',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }
}

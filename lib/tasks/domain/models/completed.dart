import 'package:timesheet_management/tasks/domain/models/task.dart';

class CompletedTask {
  final int id;
  final Tasks task;
  final int seconds;
  final int userId;

  CompletedTask(
      {required this.id,
      required this.task,
      required this.userId,
      required this.seconds});
  CompletedTask copyWith({Tasks? task, int? seconds}) {
    return CompletedTask(
      id: id,
      task: task ?? this.task,
      seconds: seconds ?? this.seconds,
      userId: userId,
    );
  }
}
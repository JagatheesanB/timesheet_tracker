import 'package:riverpod/riverpod.dart';
import 'package:timesheet_management/tasks/domain/models/completed.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/domain/repositories/task_repository.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';
import 'package:timesheet_management/tasks/utils/constants/exception.dart';

class CompletedTasksNotifier extends StateNotifier<List<CompletedTask>> {
  final TaskRepository _taskRepository;

  CompletedTasksNotifier(this._taskRepository) : super([]);

  void addCompletedTask(Tasks task, int seconds, int userId) async {
    final completedTask =
        CompletedTask(id: 0, task: task, seconds: seconds, userId: userId);
    state = [...state, completedTask];

    try {
      await _taskRepository.insertCompletedTask(task, userId, seconds);
      // print('The completed task is ${task.taskName} with $seconds seconds');
    } catch (e) {
      // print('Error adding completed task: $e');
      state = List.of(state)..removeLast();
      CustomException("Something went wrong while adding completed task");
    }
  }

  Future<List<CompletedTask>> getAllCompletedTasks(int userId) async {
    return await _taskRepository.getAllCompletedTasksByUserId(userId);
  }
}

final completedTasksprovider =
    StateNotifierProvider<CompletedTasksNotifier, List<CompletedTask>>(
  (ref) => CompletedTasksNotifier(ref.watch(taskRepositoryProvider)),
);

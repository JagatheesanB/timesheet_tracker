import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/data/repositories/task_repo_impl.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/domain/repositories/task_repository.dart';
import 'package:timesheet_management/tasks/utils/constants/exception.dart';

// typedef TaskListChange = void Function(List<Tasks> taskList);

class TaskNotifier extends StateNotifier<List<Tasks>> {
  final TaskRepository _taskRepository;
  // TaskListChange? onTaskListChange;

  TaskNotifier(this._taskRepository, List<Tasks> state) : super(state);

  Future<void> getTasksWithUserId(int userId) async {
    List<Tasks> tasks = await _taskRepository.getAllTasksWithUserId(userId);
    state = tasks;
    // onTaskListChange?.call(state);
  }

  Future<void> getAllTasks() async {
    List<Tasks> tasks = await _taskRepository.getAllTasks();
    state = tasks;
    // onTaskListChange?.call(state);
  }

  void addTask(Tasks task, int userId) async {
    await _taskRepository.insertTask(task, userId);
    state = [...state, task];
//    onTaskListChange?.call(state);
  }

  void updateTaskName(String name, int id) async {
    if (id >= 1 && id < state.length) {
      var updatedTasks = state.map((task) {
        if (task.id == id) {
          return task.copyWith(taskName: name);
        } else {
          return task;
        }
      }).toList();
      state = updatedTasks;

      try {
        await _taskRepository.editTask(
            id, updatedTasks.firstWhere((task) => task.id == id));
      } catch (e) {
        CustomException("Error in editing task $e");
      }
    }
//    onTaskListChange?.call(state);
  }

  void deleteTask(int taskId) async {
    if (state.any((task) => task.id == taskId)) {
      var taskList = List<Tasks>.from(state);
      taskList.removeWhere((task) => task.id == taskId);
      state = taskList;

      try {
        await _taskRepository.deleteTask(taskId);
      } catch (e) {
        state = List<Tasks>.from(taskList);
        CustomException("Error in deleting task $e");
      }
    } else {
      if (state.any((task) => task.id != taskId)) {
        CustomException("Task not found for delete");
      }
    }
//    onTaskListChange?.call(state);
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Tasks>>(
  (ref) => TaskNotifier(ref.watch(taskRepositoryProvider), []),
);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImplementation();
});

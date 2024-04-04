import 'package:timesheet_management/tasks/domain/models/attendance.dart';
import 'package:timesheet_management/tasks/domain/models/history.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';

import '../models/completed.dart';

abstract class TaskRepository {
  Future<bool> login(String userName, String userPassword);
  Future<void> signup(String userName, String userPassword);
  Future<bool> checkUserExists(String userName);
  Future<void> insertTask(Tasks task, int userId);
  Future<void> editTask(int taskId, Tasks task);
  Future<void> deleteTask(int taskId);
  Future<List<Tasks>> getTasksByInterval(String interval);
  Future<List<Tasks>> getAllTasks();
  Future<List<Tasks>> getAllTasksWithUserId(int userId);
  Future<int?> getUserId(String email);
  Future<void> insertCompletedTask(Tasks task, int userId, int seconds);
  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId);
  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId);
  Future<void> insertTaskForHistory(Tasks task, int userId);
  Future<List<CompletedTask>> getAllCompletedTasksByUserId(int userId);
  Future<void> storeAttendanceHistory(
      int userId, String checkInTime, String checkOutTime);
  Future<List<AttendanceRecord>> getAttendanceHistoryByUserId(String userId);
  // Future<int> insertReport(Map<String, dynamic> data);
  // Future<List<Map<String, dynamic>>> getReports();
}
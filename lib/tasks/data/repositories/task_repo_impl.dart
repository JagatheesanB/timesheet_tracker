import 'package:timesheet_management/tasks/data/dataSources/task_datasource.dart';
import 'package:timesheet_management/tasks/domain/models/attendance.dart';
import 'package:timesheet_management/tasks/domain/models/completed.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/domain/repositories/task_repository.dart';

import '../../domain/models/history.dart';

class TaskRepositoryImplementation implements TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<bool> login(String userName, String userPassword) async {
    return await _databaseHelper.login(userName, userPassword);
  }

  @override
  Future<void> signup(String userName, String userPassword) async {
    await _databaseHelper.signup(userName, userPassword);
  }

  @override
  Future<bool> checkUserExists(String userName) async {
    return await _databaseHelper.checkUserExists(userName);
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _databaseHelper.deleteTask(taskId);
  }

  @override
  Future<void> editTask(int taskId, Tasks task) async {
    await _databaseHelper.editTask(taskId, task);
  }

  @override
  Future<List<CompletedTask>> getAllCompletedTasksByUserId(int userId) async {
    return await _databaseHelper.getAllCompletedTasksByUserId(userId);
  }

  @override
  Future<List<Tasks>> getAllTasks() async {
    return await _databaseHelper.getAllTasks();
  }

  @override
  Future<List<Tasks>> getAllTasksWithUserId(int userId) async {
    return await _databaseHelper.getAllTasksWithUserId(userId);
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistoryByUserId(
      String userId) async {
    return await _databaseHelper.getAttendanceHistoryByUserId(userId);
  }

  @override
  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId) async {
    return await _databaseHelper.getTaskHistoryByUserId(userId);
  }

  @override
  Future<List<Tasks>> getTasksByInterval(String interval) async {
    return await _databaseHelper.getTasksByInterval(interval);
  }

  @override
  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId) async {
    return await _databaseHelper.getTasksFromHistoryByInterval(
        interval, userId);
  }

  @override
  Future<int?> getUserId(String email) async {
    return await _databaseHelper.getUserId(email);
  }

  @override
  Future<void> insertCompletedTask(Tasks task, int userId, int seconds) async {
    await _databaseHelper.insertCompletedTask(task, userId, seconds);
  }

  @override
  Future<void> insertTask(Tasks task, int userId) async {
    await _databaseHelper.insertTask(task, userId);
  }

//
  @override
  Future<void> insertTaskForHistory(Tasks task, int userId) async {
    await _databaseHelper.insertTaskForHistory(task, userId);
  }

//
  @override
  Future<void> storeAttendanceHistory(
      int userId, String checkInTime, String checkOutTime) async {
    await _databaseHelper.storeAttendanceHistory(
        userId, checkInTime, checkOutTime);
  }
}

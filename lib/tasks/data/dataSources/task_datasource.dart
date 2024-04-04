import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timesheet_management/tasks/domain/models/attendance.dart';
import 'package:timesheet_management/tasks/domain/models/completed.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/domain/repositories/task_repository.dart';
import 'package:timesheet_management/tasks/utils/constants/exception.dart';

import '../../domain/models/history.dart';

class DatabaseHelper implements TaskRepository {
  final String databaseName = "top.db";
  final String usersTable =
      "CREATE TABLE users (userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE, userPassword TEXT)";

  final String taskTable =
      "CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT,userId INTEGER,taskName TEXT UNIQUE, isCompleted INTEGER, dateTime TEXT, interval TEXT)";

  final String completedTasksTable =
      "CREATE TABLE completed_tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, taskName TEXT,userId INTEGER, seconds INTEGER)";

  static Database? _database;
  static DatabaseHelper? _instance;

  DatabaseHelper._(); //private so that it cannot be accessed from outside the class.

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, databaseName);
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  FutureOr<void> _createDb(db, version) async {
    await db.execute(usersTable);
    await db.execute(taskTable);
    await db.execute(completedTasksTable);
    await createHistoryTable(db);
    await createAttendanceTable(db);
  }

  Future<void> createHistoryTable(Database db) async {
    await db.execute('''
    CREATE TABLE history(
      id INTEGER PRIMARY KEY,
      taskName TEXT,
      userId INTEGER,
      dateTime TEXT
    )
  ''');
  }

  Future<void> createAttendanceTable(Database db) async {
    await db.execute('''
    CREATE TABLE attendance_history(
      id INTEGER PRIMARY KEY,
      userId INTEGER,
      checkInTime TEXT,
      checkOutTime TEXT,
      date TEXT,
      FOREIGN KEY (userId) REFERENCES users(userId)
    )
  ''');
  }

  @override
  Future<bool> login(String userName, String userPassword) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'userName = ? AND userPassword = ?',
      whereArgs: [userName, userPassword],
    );

    return result.isNotEmpty;
  }

  @override
  Future<void> signup(String userName, String userPassword) async {
    final Database db = await database;

    await db.insert(
      'users',
      {'userName': userName, 'userPassword': userPassword},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> checkUserExists(String userName) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'userName = ?',
      whereArgs: [userName],
    );
    return result.isNotEmpty;
  }

  // @override
  // Future<void> insertTask(Tasks task, int userId) async {
  //   final Database db = await database;
  //   try {
  //     await db.insert('tasks', {
  //       ...task.toMapWithOutId(),
  //       'id': task.id, // Ensure that the task's ID is used for insertion
  //       'userId': userId,
  //     });
  //   } catch (e) {
  //     CustomException("Something went wrong while inserting task");
  //   }
  // }

  // Insert Task
  @override
  Future<void> insertTask(Tasks task, int userId) async {
    final Database db = await database;

    try {
      await db.insert('tasks', {
        ...task.toMapWithOutId(),
        'id': task.id, // Ensure that the task's ID is used for insertion
        'userId': userId,
      });
    } catch (e) {
      CustomException("Something went wrong while inserting task");
    }
  }

// Edit Task
  @override
  Future<void> editTask(int taskId, Tasks task) async {
    final Database db = await database;
    try {
      await db.update(
        'tasks',
        task.toMapWithOutId(),
        where: 'id = ? ',
        whereArgs: [taskId],
      );
      // print('Task edited successfully: ${task.taskName}');
    } catch (e) {
      // print('Error editing task: $e');
      CustomException("Something went wrong while editing task");
    }
  }

  // Delete a Task
  @override
  Future<void> deleteTask(int taskId) async {
    final Database db = await database;

    try {
      await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
      // print('Task deleted successfully with ID: $taskId');
    } catch (e) {
      // print('Error deleting task: $e');
      CustomException("Something went wrong while deleting task");
    }
  }

  // Fetch tasks based on interval
  @override
  Future<List<Tasks>> getTasksByInterval(String interval) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'interval = ?',
      whereArgs: [interval],
    );

    return List.generate(maps.length, (i) {
      return Tasks(
        id: maps[i]['taskId'],
        taskName: maps[i]['taskName'],
        isCompleted: maps[i]['isCompleted'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        interval: maps[i]['interval'],
      );
    });
  }

  // Get All Tasks
  @override
  Future<List<Tasks>> getAllTasks() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Tasks(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        isCompleted: maps[i]['isCompleted'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        interval: maps[i]['interval'],
      );
    });
  }

  // Get All Tasks with UserId
  @override
  Future<List<Tasks>> getAllTasksWithUserId(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId], // Filter tasks by user ID
    );
    // print(maps);
    return List.generate(maps.length, (i) {
      return Tasks(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        isCompleted: maps[i]['isCompleted'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        interval: maps[i]['interval'],
      );
    });
  }

  // Fetch User ID
  @override
  Future<int?> getUserId(String email) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['userId'],
      where: 'userName = ?',
      whereArgs: [email],
    );
    // print(result);
    if (result.isNotEmpty) {
      return result.first['userId'] as int?;
    } else {
      return null;
    }
  }

  // Insert Complete Task
  @override
  Future<void> insertCompletedTask(Tasks task, int userId, int seconds) async {
    // print('hhhhhh $userId');
    final Database db = await database;

    try {
      await db.insert(
        'completed_tasks',
        {'taskName': task.taskName, 'userId': userId, 'seconds': seconds},
      );
      // print('Completed task added successfully: ${task.taskName}');
    } catch (e) {
      // print('Error adding completed task: $e');
      CustomException("Something went wrong while in Completed task");
    }
  }

  // Get All Completed Tasks by UserId // int? -> int
  @override
  Future<List<CompletedTask>> getAllCompletedTasksByUserId(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'completed_tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      // Check if taskId is null before casting
      int? taskId = maps[i]['taskId'] as int?;
      int taskIdNonNull = taskId ?? -1;

      return CompletedTask(
        id: maps[i]['id'],
        task: Tasks(
          id: taskIdNonNull,
          taskName: maps[i]['taskName'],
        ),
        seconds: maps[i]['seconds'] as int,
        userId: maps[i]['userId'] as int,
      );
    });
  }

  // Insert task into the history table
  @override
  Future<void> insertTaskForHistory(Tasks task, int userId) async {
    final Database db = await database;

    try {
      await db.insert(
        'history',
        {
          'taskName': task.taskName,
          'userId': userId,
          'dateTime': task.dateTime.toString(),
        },
      );
      // print('Task added to history successfully: ${task.taskName} $userId');
    } catch (e) {
      // print('Error adding task to history: $e');
      CustomException("Something went wrong while adding history task");
    }
  }

  // Method to retrieve task history based on user ID
  @override
  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId) async {
    Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    // print(maps);
    return List.generate(maps.length, (i) {
      return HistoryTask(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        userId: maps[i]['userId'],
      );
    });
  }

  // Get tasks from history table by interval (day, week, month)
  @override
  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId) async {
    final Database db = await database;

    late DateTime startDate;
    late DateTime endDate;

    switch (interval) {
      case 'day':
        startDate = DateTime.now().subtract(const Duration(days: 1));
        endDate = DateTime.now();
        break;
      case 'week':
        startDate = DateTime.now().subtract(const Duration(days: 7));
        endDate = DateTime.now();
        break;
      case 'month':
        startDate = DateTime.now().subtract(const Duration(days: 30));
        endDate = DateTime.now();
        break;
      default:
        startDate = DateTime.now().subtract(const Duration(days: 7));
        endDate = DateTime.now();
        break;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'userId = ? AND dateTime BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String()
      ],
    );

    return List.generate(maps.length, (i) {
      return HistoryTask(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        userId: maps[i]['userId'],
      );
    });
  }

  // Store attendance history for a user
  @override
  Future<void> storeAttendanceHistory(
      int userId, String checkInTime, String checkOutTime) async {
    final Database db = await database;

    try {
      await db.insert(
        'attendance_history',
        {
          'userId': userId,
          'checkInTime': checkInTime.toString(),
          'checkOutTime': checkOutTime.toString(),
          'date': DateTime.now().toString(),
        },
      );
      // print('Attendance history stored successfully for user ID: $userId');
    } catch (e) {
      // print('Error storing attendance history: $e');
      CustomException("Something went wrong while adding attendance");
    }
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistoryByUserId(
      String userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_history',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return AttendanceRecord(
        id: maps[i]['id'],
        userId: maps[i]['userId'],
        checkInTime: maps[i]['checkInTime'],
        checkOutTime: maps[i]['checkOutTime'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';

import '../../domain/models/attendance.dart';
import '../../domain/repositories/task_repository.dart';
import '../../utils/constants/exception.dart';

class AttendanceRecordNotifier extends StateNotifier<List<AttendanceRecord>> {
  final TaskRepository _taskRepository;

  AttendanceRecordNotifier(this._taskRepository) : super([]);

  Future<void> addAttendanceHistoryByUserId(
      int userId, String checkInTime, String checkOutTime) async {
    final AttendanceRecord record = AttendanceRecord(
      userId: userId,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      date: DateTime.now(),
    );

    try {
      await _taskRepository.storeAttendanceHistory(
          userId, checkInTime, checkOutTime);
      state = [...state, record];
      // print('Attendance history stored successfully for user ID: $userId');
    } catch (e) {
      // print('Error storing attendance history: $e');
      CustomException("Something went wrong while adding Attd");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceRecordsByUserId(
      String userId) async {
    final List<AttendanceRecord> records =
        await _taskRepository.getAttendanceHistoryByUserId(userId);
    state = records;
    return records.map((record) => record.toMap()).toList();
  }
}

final attendanceRecordProvider =
    StateNotifierProvider<AttendanceRecordNotifier, List<AttendanceRecord>>(
  (ref) => AttendanceRecordNotifier(ref.watch(taskRepositoryProvider)),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/presentation/providers/auth_provider.dart';
import 'package:timesheet_management/tasks/presentation/views/attendance.dart';
import 'package:timesheet_management/tasks/utils/constants/exception.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _attendanceHistory;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserProvider);
    _attendanceHistory = _getAttendanceHistory(userId!);
  }

  Future<List<Map<String, dynamic>>> _getAttendanceHistory(int userId) async {
    final List<Map<String, dynamic>> history = [];
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final checkIn = await AttendanceStorage.getCheckIn(date, userId);
      final checkOut = await AttendanceStorage.getCheckOut(date, userId);
      if (checkIn != null && checkOut != null) {
        history.add({
          'date': '${date.year}-${date.month}-${date.day}',
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
        });
      }
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        title: const Text(
          'Attendance History',
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _attendanceHistory,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final attendanceList = snapshot.data!;
            return ListView.builder(
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final attendance = attendanceList[index];
                final checkIn = DateTime.parse(attendance['checkIn']);
                final checkOut = DateTime.parse(attendance['checkOut']);
                return GestureDetector(
                  onLongPress: () {
                    _showDeleteConfirmationDialog(attendance['date']);
                  },
                  child: Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${attendance['date']}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Check-In: ${_formatDateTime(checkIn)}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Spacer(),
                              Text(
                                'Check-Out: ${_formatDateTime(checkOut)}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteConfirmationDialog(String date) async {
    final userId = ref.read(currentUserProvider);
    final now = _parseDateString(date);
    if (now != null) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Entry'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to delete this entry?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  await AttendanceStorage.deleteEntry(now, userId!);
                  setState(() {
                    _attendanceHistory = _getAttendanceHistory(userId);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  DateTime? _parseDateString(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      CustomException("Error parsing date: $e");
    }
    return null; // Return null if parsing fails
  }
}

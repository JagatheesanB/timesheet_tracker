import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/history.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';

class TimesheetHistoryPage extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final List<HistoryTask> historyTask;

  const TimesheetHistoryPage({
    Key? key,
    required this.selectedDate,
    required this.historyTask,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TimesheetHistoryPageState();
}

class _TimesheetHistoryPageState extends ConsumerState<TimesheetHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider);
    final historyTaskList = ref.watch(taskHistoryProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (historyTaskList.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.amber.shade100,
        appBar: _buildAppBar(context),
        body: _buildTaskList(context, historyTaskList),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.amber.shade100,
        appBar: _buildAppBar(context),
        body: _buildEmptyState(context),
      );
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.amber.shade100,
      title: Text(
        AppLocalizations.of(context)!.historyTask,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            _buildPopupMenuItem('DAY', Icons.calendar_today),
            _buildPopupMenuItem('WEEK', Icons.calendar_view_week),
            _buildPopupMenuItem('MONTH', Icons.calendar_view_month),
          ],
          onSelected: (value) {
            _handleMenuItemSelected(value);
          },
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.redAccent.shade700),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  void _handleMenuItemSelected(String value) {
    final userId = ref.watch(currentUserProvider);
    final historyTaskNotifier = ref.read(taskHistoryProvider.notifier);
    if (userId != null) {
      switch (value) {
        case 'DAY':
          historyTaskNotifier.getTasksFromHistoryByInterval('day', userId);
          break;
        case 'WEEK':
          historyTaskNotifier.getTasksFromHistoryByInterval('week', userId);
          break;
        case 'MONTH':
          historyTaskNotifier.getTasksFromHistoryByInterval('month', userId);
          break;
        default:
          break;
      }
    }
  }

  Widget _buildTaskList(BuildContext context, List<HistoryTask> tasks) {
    return ListView.builder(
      itemCount: widget.historyTask.length,
      itemBuilder: (context, index) {
        final historyTask = widget.historyTask[index];
        final formattedDateTime =
            DateFormat.yMMMMd('en_US').format(historyTask.dateTime);
        return Card(
          margin: const EdgeInsets.all(8.0), // Add margin
          elevation: 4.0,
          color: const Color.fromARGB(255, 199, 93, 86),
          child: ListTile(
            leading: const Icon(
              Icons.arrow_right_alt_outlined,
              color: Colors.white,
            ), // Add leading icon
            title: Text(
              historyTask.taskName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              formattedDateTime,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/empty.json',
            width: 170,
            height: 170,
          ),
          const SizedBox(height: 20),
          const Text(
            'Currently History not found',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

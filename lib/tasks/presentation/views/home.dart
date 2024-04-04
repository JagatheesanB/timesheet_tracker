import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timesheet_management/tasks/presentation/providers/completed_provider.dart';
import 'package:timesheet_management/tasks/presentation/views/add_task.dart';
import 'package:timesheet_management/tasks/presentation/views/completed_task.dart';
import 'package:timesheet_management/tasks/presentation/views/login_page.dart';
import 'package:timesheet_management/tasks/presentation/widgets/day_tab.dart';
import 'package:timesheet_management/tasks/domain/models/task.dart';
import 'package:timesheet_management/tasks/presentation/views/history_page.dart';
import 'package:timesheet_management/tasks/presentation/widgets/month_tab.dart';
import 'package:timesheet_management/tasks/presentation/providers/task_provider.dart';
import 'package:timesheet_management/tasks/presentation/views/sidebar.dart';
import 'package:timesheet_management/tasks/presentation/widgets/week_tab.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/completed.dart';
import '../../domain/models/history.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({
    Key? key,
    required this.email,
  }) : super(key: key);
  final String? email;

  @override
  ConsumerState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  final GlobalKey<DayPageState> dayPageKey = GlobalKey<DayPageState>();

  final List<Tasks> taskList = Tasks.taskList();
  late List<Tasks> _filteredTasks;
  final List<Tasks> completedTasks = [];
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  String selectedInterval = 'DAY';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredTasks = [...taskList];
    // loadData();
    final userId = ref.read(currentUserProvider);
    if (userId != null) {
      load(userId);
    }
  }

  void _setSelectedInterval(String interval) {
    setState(() {
      selectedInterval = interval;
    });
  }

  void _completeTask(Tasks task) {
    setState(() {
      _filteredTasks.remove(task);
      completedTasks.add(task);
    });
  }

  void _navigateToTimesheetHistoryPage() async {
    int? userId = ref.read(currentUserProvider);
    List<HistoryTask> tasks = await ref
        .read(taskHistoryProvider.notifier)
        .getTaskHistoryByUserId(userId!);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimesheetHistoryPage(
            selectedDate: _selectedDate,
            historyTask: tasks,
          ),
        ),
      );
    }
  }

  void _navigateToCompletedTasksPage() async {
    int? userId = ref.read(currentUserProvider);
    if (userId != null) {
      List<CompletedTask> tasks = await ref
          .read(completedTasksprovider.notifier)
          .getAllCompletedTasks(userId);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletedTasksPage(
              completedTask: tasks,
            ),
          ),
        );
      }
    } else {}
  }

  loadData() {
    ref.read(taskProvider.notifier).getAllTasks();
  }

  load(int userId) {
    ref.read(taskProvider.notifier).getTasksWithUserId(userId);
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.amber.shade100,
        drawer: Tooltip(
          message: 'Menu',
          child: Sidebar(
            onLogout: logout,
            email: widget.email!,
          ),
        ),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                _buildTabBar(),
                const SizedBox(
                  height: 10,
                ),
                _week(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Consumer(builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        return DayPage(
                          taskList: _filteredTasks,
                          key: dayPageKey,
                          completeTask: _completeTask,
                          deleteTask: (Tasks taskToDelete) {
                            setState(() {
                              _filteredTasks.remove(taskToDelete);
                            });
                          },
                        );
                      }),
                      WeekPage(
                        taskList: _filteredTasks,
                        // key: weekPageKey,
                        selectedDate: DateTime.now(),
                        completeTask: _completeTask,
                        deleteTask: (Tasks taskToDelete) {
                          setState(() {
                            _filteredTasks.remove(taskToDelete);
                          });
                        },
                      ),
                      MonthTab(
                        taskList: _filteredTasks,
                        // key: monthPageKey,
                        completeTask: _completeTask,
                        deleteTask: (Tasks taskToDelete) {
                          setState(() {
                            _filteredTasks.remove(taskToDelete);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // _searchButton(),
          ],
        ),
        floatingActionButton:
            Tooltip(message: 'Add', child: _addButton(context)),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  FloatingActionButton _addButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'btn1',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTask(
              // onTask: _task,
              onIntervalSelected: _setSelectedInterval,
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.redAccent.shade700,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.amber.shade100,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'My Timesheets',
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(''),
            ),
          ),
          Tooltip(
            message: 'Completed',
            child: IconButton(
              onPressed: _navigateToCompletedTasksPage,
              icon: const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.black),
            ),
          ),
          Tooltip(
            message: 'History',
            child: IconButton(
              onPressed: _navigateToTimesheetHistoryPage,
              icon: const Icon(Icons.history, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelColor: Colors.red,
      controller: _tabController,
      indicatorColor: const Color.fromARGB(255, 212, 29, 29),
      tabs: [
        Tab(text: AppLocalizations.of(context)!.day),
        Tab(text: AppLocalizations.of(context)!.week),
        Tab(text: AppLocalizations.of(context)!.month),
      ],
    );
  }

  Widget _week() {
    return Visibility(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.redAccent,
            ),
          ),
          Text(
            _getFormattedDate(),
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
            },
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    return DateFormat('MMMM').format(_selectedDate);
  }
}

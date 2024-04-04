import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/presentation/views/login_page.dart';
import 'package:timesheet_management/tasks/presentation/views/attendance.dart';
import 'package:timesheet_management/tasks/presentation/views/api_task_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/language_provider.dart';

class Sidebar extends ConsumerStatefulWidget {
  final void Function() onLogout;
  final String email;

  const Sidebar({
    Key? key,
    required this.onLogout,
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  late Locale _locale;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _loadLocale();
    super.didChangeDependencies();
  }

  void _loadLocale() {
    _locale = ref.watch(selectedLocaleProvider);
  }

  @override
  Widget build(BuildContext context) {
    final emailPrefix = widget.email.split('@').first.toUpperCase();

    return Drawer(
      backgroundColor: Colors.amber.shade100,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.pink,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emailPrefix,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<Locale>(
                  icon: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _locale.languageCode.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (BuildContext context) {
                    return languages;
                  },
                  onSelected: (value) {
                    setState(() {
                      _locale = value;
                    });
                    ref
                        .read(selectedLocaleProvider.notifier)
                        .changeLocale(value);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.access_time_outlined,
              color: Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.attendance,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceLocationScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.task_outlined,
              color: Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.tasks,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TaskListPage()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person_4_outlined,
              color: Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.login,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app_outlined,
              color: Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            onTap: () {
              widget.onLogout();
            },
          ),
        ],
      ),
    );
  }

  // chose Language
  List<PopupMenuEntry<Locale>> get languages {
    return [
      const PopupMenuItem(
        value: Locale('en'),
        child: Text('English'),
      ),
      const PopupMenuItem(
        value: Locale('hi'),
        child: Text('Hindi'),
      ),
      const PopupMenuItem(
        value: Locale('fr'),
        child: Text('French'),
      ),
      const PopupMenuItem(value: Locale('zh'), child: Text('Chinese')),
    ];
  }
}

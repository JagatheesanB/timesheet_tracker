import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timesheet_management/tasks/domain/models/completed.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompletedTasksPage extends ConsumerStatefulWidget {
  const CompletedTasksPage({Key? key, required this.completedTask})
      : super(key: key);

  final List<CompletedTask> completedTask;

  @override
  ConsumerState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends ConsumerState<CompletedTasksPage> {
  void loadCompletedTasks() async {}

  @override
  Widget build(BuildContext context) {
    loadCompletedTasks();
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        title: Text(
          AppLocalizations.of(context)!.completedTask,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.completedTask.isEmpty
          ? Stack(
              children: [
                Center(
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
                        'No Completed Tasks',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: widget.completedTask.length,
              itemBuilder: (context, index) {
                final completedTask = widget.completedTask[index];
                String displayTime =
                    '${(completedTask.seconds ~/ 3600).toString().padLeft(2, '0')}'
                    ':${((completedTask.seconds ~/ 60) % 60).toString().padLeft(2, '0')}'
                    ':${(completedTask.seconds % 60).toString().padLeft(2, '0')}';
                String share = completedTask.task.taskName;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      completedTask.task.taskName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Time spent: $displayTime',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    trailing:
                        const Icon(Icons.done_all, color: Colors.redAccent),
                    onTap: () async {
                      await Share.shareWithResult(
                          'Completed Task : $share $displayTime');
                      // print(result.status);
                    },
                  ),
                );
              },
            ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:timesheet_management/tasks/domain/models/completed.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:timesheet_management/tasks/presentation/providers/auth_provider.dart';
// import 'package:timesheet_management/tasks/presentation/providers/completed_provider.dart';
// class CompletedTasksPage extends ConsumerStatefulWidget {
//   const CompletedTasksPage({Key? key, required this.completedTask})
//       : super(key: key);

//   final List<CompletedTask> completedTask;

//   @override
//   ConsumerState createState() => _CompletedTasksPageState();
// }
// class _CompletedTasksPageState extends ConsumerState<CompletedTasksPage> {
//   late List<CompletedTask> completedTasks;
//   void initState() {
//     super.initState();
//     completedTasks = [];
//     loadCompletedTasks();
//   }

//   void loadCompletedTasks() {
//     final userId = ref.read(currentUserProvider);
//     ref
//         .read(completedTasksprovider.notifier)
//         .getAllCompletedTasks(userId!)
//         .then((tasks) {
//       if (mounted) {
//         setState(() {
//           completedTasks = tasks;
//         });
//       }
//     }).catchError((error) {
//       // Handle any errors that occur during data retrieval
//       print('Error loading completed tasks: $error');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     loadCompletedTasks();
//     return Scaffold(
//       backgroundColor: Colors.amber.shade100,
//       appBar: AppBar(
//         backgroundColor: Colors.amber.shade100,
//         title: Text(
//           AppLocalizations.of(context)!.completedTask,
//           style: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: widget.completedTask.isEmpty
//           ? Stack(
//               children: [
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Lottie.asset(
//                         'assets/lottie/empty.json',
//                         width: 170,
//                         height: 170,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'No Completed Tasks',
//                         style: TextStyle(
//                           fontStyle: FontStyle.italic,
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : ListView.builder(
//               itemCount: widget.completedTask.length,
//               itemBuilder: (context, index) {
//                 final completedTask = widget.completedTask[index];
//                 String displayTime =
//                     '${(completedTask.seconds ~/ 3600).toString().padLeft(2, '0')}'
//                     ':${((completedTask.seconds ~/ 60) % 60).toString().padLeft(2, '0')}'
//                     ':${(completedTask.seconds % 60).toString().padLeft(2, '0')}';
//                 String share = completedTask.task.taskName;
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 8.0, horizontal: 16.0),
//                   child: ListTile(
//                     title: Text(
//                       completedTask.task.taskName,
//                       style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     subtitle: Text(
//                       'Time spent: $displayTime',
//                       style: const TextStyle(fontFamily: 'Poppins'),
//                     ),
//                     trailing:
//                         const Icon(Icons.done_all, color: Colors.redAccent),
//                     onTap: () async {
//                       await Share.shareWithResult(
//                           'Completed Task : $share $displayTime');
//                       // print(result.status);
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

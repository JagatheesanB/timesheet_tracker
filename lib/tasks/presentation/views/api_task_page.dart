// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/models/api_task.dart';
// class TaskListPage extends ConsumerStatefulWidget {
//   const TaskListPage({Key? key}) : super(key: key);
//   @override
//   ConsumerState createState() => _TaskListPageState();
// }
// class _TaskListPageState extends ConsumerState<TaskListPage> {
//   late List<Task> tasks = [];
//   @override
//   void initState() {
//     super.initState();
//     // fetchTasks();
//     fetchTasks();
//   }
//   void fetchTasks() async {
//     final List<Task> fetchedTasks = await ApiCallForTask().fetchTasks();
//     setState(() {
//       tasks = fetchedTasks;
//     });
//   }
//   void toggleTaskCompletion(int index) {
//     setState(() {
//       tasks[index].isCompleted = !tasks[index].isCompleted;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amber.shade100,
//       appBar: AppBar(
//         backgroundColor: Colors.amber.shade100,
//         title: const Text(
//           'Task List',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: tasks.isNotEmpty
//           ? ListView.builder(
//               itemCount: tasks.length,
//               itemBuilder: (context, index) {
//                 final task = tasks[index];
//                 return SizedBox(
//                   width: MediaQuery.of(context).size.width *
//                       0.8, // Adjust width here
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.all(4.0),
//                     decoration: BoxDecoration(
//                       color: task.isCompleted
//                           ? Colors.green.shade100
//                           : Colors.red.shade100,
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: ListTile(
//                       onTap: () => toggleTaskCompletion(index),
//                       title: Text(
//                         'ID: ${task.id}',
//                         style: TextStyle(
//                           color: task.isCompleted ? Colors.green : Colors.red,
//                         ),
//                       ),
//                       subtitle: Text(
//                         task.taskName,
//                         style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       trailing: task.isCompleted
//                           ? const Icon(Icons.check_circle, color: Colors.green)
//                           : const Icon(Icons.radio_button_unchecked,
//                               color: Colors.red),
//                     ),
//                   ),
//                 );
//               },
//             )
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/api_task.dart';
import '../providers/api_provider.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = ref.read(apiProvider);
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    ref.read(apiProvider.notifier).state = _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        title: const Text(
          'Task List',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ),
      body: _tasks.isNotEmpty
          ? ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      onTap: () => toggleTaskCompletion(index),
                      title: Text(
                        'ID: ${task.id}',
                        style: TextStyle(
                          color: task.isCompleted ? Colors.green : Colors.red,
                        ),
                      ),
                      subtitle: Text(
                        task.taskName,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: task.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.radio_button_unchecked,
                              color: Colors.red),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

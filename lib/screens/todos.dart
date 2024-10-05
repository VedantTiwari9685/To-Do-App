import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/priority.dart';
import 'package:todo_app/models/todo_task.dart';
import 'package:todo_app/screens/add_todo_screen.dart';
import 'package:todo_app/widgets/main_drawer.dart';
import 'package:todo_app/widgets/todo_checkbox_tile.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _todoStream =
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('todos')
          .orderBy('deadline', descending: false)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarOpacity: 1,
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                color: Colors.white,
                icon: const Icon(Icons.menu),
              );
            },
          ),
          title: Text(
            "To-Do List",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddTodoScreen()),
                );
              },
              icon: Icon(
                Icons.add,
                size: 24,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: Text('Add Task',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary)),
            )
          ],
        ),
        drawer: const MainDrawer(),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _todoStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No tasks found'));
            }

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final todoDoc = snapshot.data!.docs[index];
                  final todoTask = TodoTask.fromJson(todoDoc.data());

                  return Dismissible(
                    key: Key(todoDoc.id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.75),
                          borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Task'),
                          content: Text(
                              'Are you sure you want to delete "${todoTask.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('todos')
                          .doc(todoDoc.id)
                          .delete();
                    },
                    child: GestureDetector(
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTodoScreen(
                              todoTask: todoTask, // Pass the todoTask object
                              todoDocId: todoDoc.id, // Pass the document ID
                            ),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: todoTask.isCompleted ? 0.5 : 1.0,
                        child: Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      todoTask.name.length > 10
                                          ? '${todoTask.name.substring(0, 10)}...'
                                          : todoTask.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Spacer(),
                                    TodoItemTile(
                                      todoTask: todoTask,
                                      todoDoc: todoDoc,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.date_range_sharp),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            todoTask.deadline),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      todoTask.priority.name.toUpperCase(),
                                      style: TextStyle(
                                        color:
                                            todoTask.priority == Priority.urgent
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.timer),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${todoTask.estimatedDuration.inHours}h ${todoTask.estimatedDuration.inMinutes % 60}min',
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ));
  }
}
// title: Text(todoTask.name),
// Text('${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(todoTask.deadline))}\nEstimated Duration: ${todoTask.estimatedDuration.inHours}h ${todoTask.estimatedDuration.inMinutes % 60}min',),

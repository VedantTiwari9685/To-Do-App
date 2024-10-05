import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_task.dart';

class TodoItemTile extends StatelessWidget {
  final TodoTask todoTask;
  final DocumentSnapshot<Map<String, dynamic>> todoDoc;

  const TodoItemTile({
    super.key,
    required this.todoTask,
    required this.todoDoc,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompleted = todoTask.isCompleted;

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Checkbox(
              value: isCompleted,
              onChanged: (value) {
                isCompleted = value!;
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('todos')
                    .doc(todoDoc.id)
                    .update({'isCompleted': value});
              },
            ),
          ),
          Text(
            isCompleted ? "Done" : "Remaining",
            style: TextStyle(
                color: isCompleted
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

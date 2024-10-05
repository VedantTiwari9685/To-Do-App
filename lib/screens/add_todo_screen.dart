import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/models/priority.dart';
import 'package:todo_app/models/todo_task.dart';

class AddTodoScreen extends StatefulWidget {
  final TodoTask? todoTask;
  final String? todoDocId;
  const AddTodoScreen({super.key, this.todoTask, this.todoDocId});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isSaving = false;

  final _nameController = TextEditingController();
  final _deadlineController = TextEditingController();

  final _hourController = TextEditingController(text: '0');
  final _minuteController = TextEditingController(text: '30');

  Categories _selectedCategory = Categories.study;
  Priority _selectedPriority = Priority.moderate;

  @override
  void initState() {
    super.initState();

    if (widget.todoTask != null) {
      _nameController.text = widget.todoTask!.name;
      _deadlineController.text = DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(widget.todoTask!.deadline),
      );
      _hourController.text =
          widget.todoTask!.estimatedDuration.inHours.toString();
      _minuteController.text =
          (widget.todoTask!.estimatedDuration.inMinutes % 60).toString();
      _selectedCategory = widget.todoTask!.categories;
      _selectedPriority = widget.todoTask!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time Required"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _hourController,
                          decoration: const InputDecoration(
                            labelText: 'Hours',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.trim().contains(RegExp(r'^[0-9]+$'))) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextFormField(
                          controller: _minuteController,
                          decoration: const InputDecoration(
                            labelText: 'Minutes',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.trim().contains(RegExp(r'^[0-9]+$'))) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      DropdownButton(
                        value: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        items: Categories.values
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                      category.name.toUpperCase().toString()),
                                ))
                            .toList(),
                      ),
                      const Spacer(),
                      DropdownButton(
                        value: _selectedPriority,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                        items: Priority.values
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(
                                      priority.name.toUpperCase().toString()),
                                ))
                            .toList(),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 16),
                          Text(_deadlineController.text.isEmpty
                              ? "Select Deadline"
                              : _deadlineController.text),
                          IconButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                // Update UI with selected date using setState
                                setState(() {
                                  final formatter = DateFormat('yyyy-MM-dd');
                                  _deadlineController.text =
                                      formatter.format(pickedDate);
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_month),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            try {
                              setState(() {
                                _isSaving = true;
                              });
                              final hours = int.parse(_hourController.text);
                              final minutes = int.parse(_minuteController.text);

                              final duration =
                                  Duration(hours: hours, minutes: minutes);

                              final todoTask = TodoTask(
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                name: _nameController.text,
                                deadline:
                                    DateTime.parse(_deadlineController.text)
                                        .millisecondsSinceEpoch,
                                estimatedDuration: duration,
                                categories: _selectedCategory,
                                priority: _selectedPriority,
                                isCompleted: false,
                              );

                              if (widget.todoDocId != null) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('todos')
                                    .doc(widget.todoDocId)
                                    .update(todoTask.toJson())
                                    .then((_) {
                                  Navigator.pop(context);
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Error updating todo: $error')),
                                  );
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('todos')
                                    .add(todoTask.toJson())
                                    .then((DocumentReference doc) {
                                  todoTask.id = doc.id;
                                  Navigator.pop(context);
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error adding todo: $error')),
                                  );
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid duration format')),
                              );
                            }
                          }
                        },
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Add Todo'),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateTimePicker extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;

  const DateTimePicker({
    super.key,
    required this.controller,
    required this.decoration,
    this.validator,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: widget.decoration,
      validator: widget.validator,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          widget.controller.text =
              '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
        }
      },
    );
  }
}

import 'package:todo_app/models/category.dart';
import 'package:todo_app/models/priority.dart';

class TodoTask {
  String id;
  String userId;
  String name;
  int deadline; // milliseconds since epoch
  Duration estimatedDuration;
  Categories categories;
  Priority priority;
  bool isCompleted;

  TodoTask({
    this.id = '',
    required this.userId,
    required this.name,
    required this.deadline,
    required this.estimatedDuration,
    required this.categories,
    required this.priority,
    required this.isCompleted,
  });

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      deadline: json['deadline'] as int, // explicit type cast
      isCompleted: json['isCompleted'] ?? false,
      estimatedDuration: Duration(seconds: json['estimatedDuration']),
      categories: Categories.values
          .firstWhere((element) => element.toString() == json['categories']),
      priority: Priority.values
          .firstWhere((element) => element.toString() == json['priority']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'deadline': deadline,
        'estimatedDuration': estimatedDuration.inSeconds,
        'isCompleted': isCompleted,
        'categories': categories.toString(),
        'priority': priority.toString(),
      };

  // Consider adding a method to convert deadline to DateTime
  DateTime get deadlineDateTime =>
      DateTime.fromMillisecondsSinceEpoch(deadline);
}

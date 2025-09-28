import 'package:flutter/material.dart';
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/services/task_service.dart';

class TaskState extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await TaskService().fetchAllTasks();
    notifyListeners();
  }
}

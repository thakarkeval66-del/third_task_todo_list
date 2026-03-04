import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import '../services/notification_service.dart';

class TodoProvider with ChangeNotifier {
  Box<Todo>? _todoBox;
  List<Todo> _todos = [];
  String _searchQuery = '';
  Timer? _ticker;

  List<Todo> get todos {
    if (_searchQuery.isEmpty) {
      return _todos;
    }
    return _todos
        .where((todo) =>
            todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            todo.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  TodoProvider() {
    _initHive();
    _startTicker();
  }

  Future<void> _initHive() async {
    _todoBox = Hive.box<Todo>('todos');
    _todos = _todoBox!.values.toList();
    notifyListeners();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool changed = false;
      for (var todo in _todos) {
        if (todo.status == TodoStatus.inProgress && todo.lastStartedAt != null) {
          final now = DateTime.now();
          final elapsed = now.difference(todo.lastStartedAt!).inSeconds;
          if (elapsed >= 1) {
            todo.remainingSeconds -= elapsed;
            todo.lastStartedAt = now;

            if (todo.remainingSeconds <= 0) {
              todo.remainingSeconds = 0;
              todo.status = TodoStatus.done;
              todo.lastStartedAt = null;
              NotificationService.showNotification(
                id: todo.id.hashCode,
                title: 'Task Completed',
                body: '${todo.title} has finished!',
              );
            }
            todo.save();
            changed = true;
          }
        }
      }
      if (changed) {
        notifyListeners();
      }
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await _todoBox!.add(todo);
    _todos.add(todo);
    notifyListeners();
  }

  Future<void> updateTodo(int index, Todo todo) async {
    final originalIndex = _todos.indexWhere((t) => t.id == todo.id);
    if (originalIndex != -1) {
      await _todoBox!.putAt(originalIndex, todo);
      _todos[originalIndex] = todo;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      await _todoBox!.deleteAt(index);
      _todos.removeAt(index);
      notifyListeners();
    }
  }

  void toggleStatus(Todo todo) {
    if (todo.status == TodoStatus.todo || todo.status == TodoStatus.inProgress) {
       if (todo.status == TodoStatus.inProgress) {
         todo.status = TodoStatus.todo;
         todo.lastStartedAt = null;
       } else {
         todo.status = TodoStatus.inProgress;
         todo.lastStartedAt = DateTime.now();
       }
       todo.save();
       notifyListeners();
    }
  }

  void markAsDone(Todo todo) {
    todo.status = TodoStatus.done;
    todo.lastStartedAt = null;
    todo.save();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

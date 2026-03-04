import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
enum TodoStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  TodoStatus status;

  @HiveField(4)
  int totalSeconds;

  @HiveField(5)
  int remainingSeconds;

  @HiveField(6)
  DateTime? lastStartedAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.status = TodoStatus.todo,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.lastStartedAt,
  });

  Todo copyWith({
    String? title,
    String? description,
    TodoStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    DateTime? lastStartedAt,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
    );
  }
}

// lib/core/data/local/collection/task.dart
import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;

  late String description;

  DateTime? createdAt; // Changed from 'late int' to 'int' with default value

  @enumerated
  late TaskStatus status;

  // Constructor
  Task({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.description,
    DateTime? createdAt,
    this.status = TaskStatus.ready,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper method to create from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? Isar.autoIncrement,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] ?? DateTime.now(),
      status: TaskStatus.values.firstWhere(
        (TaskStatus status) => status.name == map['status'],
        orElse: () => TaskStatus.ready,
      ),
    );
  }

  // Helper method to convert to Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'status': status.name,
    };
  }

  // Get formatted creation date
  DateTime? get createdDate => createdAt;

  // Get status as string
  String get statusString => status.name;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, createdAt: $createdAt, status: ${status.name})';
  }
}

enum TaskStatus { ready, pending, completed }

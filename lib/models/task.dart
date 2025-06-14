import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  TaskPriority priority;

  @HiveField(4)
  TaskStatus status;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? dueDate;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  int estimatedEffort; // in minutes

  @HiveField(9)
  int actualEffort; // in minutes

  @HiveField(10)
  String? projectId;

  @HiveField(11)
  List<String> tags;

  @HiveField(12)
  List<String> contexts;

  @HiveField(13)
  List<Subtask> subtasks;

  @HiveField(14)
  String? parentTaskId;

  @HiveField(15)
  bool isRecurring;

  @HiveField(16)
  RecurrencePattern? recurrencePattern;

  @HiveField(17)
  int sortOrder;

  @HiveField(18)
  DateTime? lastModified;

  @HiveField(19)
  bool isArchived;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    this.dueDate,
    this.completedAt,
    this.estimatedEffort = 0,
    this.actualEffort = 0,
    this.projectId,
    List<String>? tags,
    List<String>? contexts,
    List<Subtask>? subtasks,
    this.parentTaskId,
    this.isRecurring = false,
    this.recurrencePattern,
    this.sortOrder = 0,
    DateTime? lastModified,
    this.isArchived = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        tags = tags ?? [],
        contexts = contexts ?? [],
        subtasks = subtasks ?? [];

  // Computed properties
  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue => dueDate != null && 
                       dueDate!.isBefore(DateTime.now()) && 
                       !isCompleted;
  
  double get completionPercentage {
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;
    return completedSubtasks / subtasks.length;
  }

  int get remainingSubtasks => subtasks.where((s) => !s.isCompleted).length;

  // Methods
  void markCompleted() {
    status = TaskStatus.completed;
    completedAt = DateTime.now();
    lastModified = DateTime.now();
  }

  void markIncomplete() {
    status = TaskStatus.todo;
    completedAt = null;
    lastModified = DateTime.now();
  }

  void addSubtask(String title) {
    subtasks.add(Subtask(title: title));
    lastModified = DateTime.now();
  }

  void removeSubtask(String id) {
    subtasks.removeWhere((s) => s.id == id);
    lastModified = DateTime.now();
  }

  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      lastModified = DateTime.now();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
    lastModified = DateTime.now();
  }

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    int? estimatedEffort,
    String? projectId,
    List<String>? tags,
    List<String>? contexts,
    bool? isRecurring,
    RecurrencePattern? recurrencePattern,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt,
      estimatedEffort: estimatedEffort ?? this.estimatedEffort,
      actualEffort: actualEffort,
      projectId: projectId ?? this.projectId,
      tags: tags ?? List.from(this.tags),
      contexts: contexts ?? List.from(this.contexts),
      subtasks: List.from(subtasks),
      parentTaskId: parentTaskId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      sortOrder: sortOrder,
      lastModified: DateTime.now(),
      isArchived: isArchived,
    );
  }
}

@HiveType(typeId: 3)
class Subtask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? completedAt;

  Subtask({
    String? id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  void toggle() {
    isCompleted = !isCompleted;
    completedAt = isCompleted ? DateTime.now() : null;
  }
}

@HiveType(typeId: 4)
class RecurrencePattern extends HiveObject {
  @HiveField(0)
  RecurrenceType type;

  @HiveField(1)
  int interval;

  @HiveField(2)
  List<int>? daysOfWeek; // 1-7, Monday-Sunday

  @HiveField(3)
  int? dayOfMonth;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  int? maxOccurrences;

  RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.maxOccurrences,
  });
}

@HiveType(typeId: 5)
enum RecurrenceType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly
}
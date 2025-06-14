import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

part 'project.g.dart';

@HiveType(typeId: 6)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int colorValue; // Store color as int

  @HiveField(4)
  String? iconName; // SF Symbol name

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? lastModified;

  @HiveField(7)
  bool isArchived;

  @HiveField(8)
  int sortOrder;

  @HiveField(9)
  DateTime? dueDate;

  @HiveField(10)
  ProjectStatus status;

  Project({
    String? id,
    required this.name,
    this.description = '',
    Color? color,
    this.iconName,
    DateTime? createdAt,
    DateTime? lastModified,
    this.isArchived = false,
    this.sortOrder = 0,
    this.dueDate,
    this.status = ProjectStatus.active,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        colorValue = (color ?? Colors.blue).value;

  Color get color => Color(colorValue);
  
  set color(Color newColor) {
    colorValue = newColor.value;
    lastModified = DateTime.now();
  }

  Project copyWith({
    String? name,
    String? description,
    Color? color,
    String? iconName,
    bool? isArchived,
    DateTime? dueDate,
    ProjectStatus? status,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt,
      lastModified: DateTime.now(),
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}

@HiveType(typeId: 7)
enum ProjectStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  onHold,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled
}
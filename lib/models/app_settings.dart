import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 8)
class AppSettings extends HiveObject {
  @HiveField(0)
  ThemeMode themeMode;

  @HiveField(1)
  TaskViewMode defaultViewMode;

  @HiveField(2)
  bool showCompletedTasks;

  @HiveField(3)
  bool enableNotifications;

  @HiveField(4)
  int defaultReminderMinutes;

  @HiveField(5)
  bool enableNaturalLanguageEntry;

  @HiveField(6)
  bool enableKeyboardShortcuts;

  @HiveField(7)
  bool enableDragAndDrop;

  @HiveField(8)
  TaskSortOrder defaultSortOrder;

  @HiveField(9)
  bool groupByProject;

  @HiveField(10)
  bool showSubtaskProgress;

  @HiveField(11)
  bool enableFocusMode;

  @HiveField(12)
  int focusModeMaxTasks;

  @HiveField(13)
  bool enableiCloudSync;

  @HiveField(14)
  bool enableSpotlightIntegration;

  @HiveField(15)
  bool showMenuBarIcon;

  @HiveField(16)
  String dateFormat;

  @HiveField(17)
  String timeFormat;

  @HiveField(18)
  double windowWidth;

  @HiveField(19)
  double windowHeight;

  @HiveField(20)
  double sidebarWidth;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultViewMode = TaskViewMode.list,
    this.showCompletedTasks = false,
    this.enableNotifications = true,
    this.defaultReminderMinutes = 15,
    this.enableNaturalLanguageEntry = true,
    this.enableKeyboardShortcuts = true,
    this.enableDragAndDrop = true,
    this.defaultSortOrder = TaskSortOrder.dueDate,
    this.groupByProject = false,
    this.showSubtaskProgress = true,
    this.enableFocusMode = false,
    this.focusModeMaxTasks = 3,
    this.enableiCloudSync = false,
    this.enableSpotlightIntegration = true,
    this.showMenuBarIcon = true,
    this.dateFormat = 'MMM d, yyyy',
    this.timeFormat = 'h:mm a',
    this.windowWidth = 1200,
    this.windowHeight = 800,
    this.sidebarWidth = 280,
  });
}

@HiveType(typeId: 9)
enum TaskViewMode {
  @HiveField(0)
  list,
  @HiveField(1)
  kanban,
  @HiveField(2)
  calendar,
  @HiveField(3)
  timeline
}

@HiveType(typeId: 10)
enum TaskSortOrder {
  @HiveField(0)
  dueDate,
  @HiveField(1)
  priority,
  @HiveField(2)
  created,
  @HiveField(3)
  modified,
  @HiveField(4)
  alphabetical,
  @HiveField(5)
  manual
}
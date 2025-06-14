// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 8;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      defaultViewMode: fields[1] as TaskViewMode,
      showCompletedTasks: fields[2] as bool,
      enableNotifications: fields[3] as bool,
      defaultReminderMinutes: fields[4] as int,
      enableNaturalLanguageEntry: fields[5] as bool,
      enableKeyboardShortcuts: fields[6] as bool,
      enableDragAndDrop: fields[7] as bool,
      defaultSortOrder: fields[8] as TaskSortOrder,
      groupByProject: fields[9] as bool,
      showSubtaskProgress: fields[10] as bool,
      enableFocusMode: fields[11] as bool,
      focusModeMaxTasks: fields[12] as int,
      enableiCloudSync: fields[13] as bool,
      enableSpotlightIntegration: fields[14] as bool,
      showMenuBarIcon: fields[15] as bool,
      dateFormat: fields[16] as String,
      timeFormat: fields[17] as String,
      windowWidth: fields[18] as double,
      windowHeight: fields[19] as double,
      sidebarWidth: fields[20] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.defaultViewMode)
      ..writeByte(2)
      ..write(obj.showCompletedTasks)
      ..writeByte(3)
      ..write(obj.enableNotifications)
      ..writeByte(4)
      ..write(obj.defaultReminderMinutes)
      ..writeByte(5)
      ..write(obj.enableNaturalLanguageEntry)
      ..writeByte(6)
      ..write(obj.enableKeyboardShortcuts)
      ..writeByte(7)
      ..write(obj.enableDragAndDrop)
      ..writeByte(8)
      ..write(obj.defaultSortOrder)
      ..writeByte(9)
      ..write(obj.groupByProject)
      ..writeByte(10)
      ..write(obj.showSubtaskProgress)
      ..writeByte(11)
      ..write(obj.enableFocusMode)
      ..writeByte(12)
      ..write(obj.focusModeMaxTasks)
      ..writeByte(13)
      ..write(obj.enableiCloudSync)
      ..writeByte(14)
      ..write(obj.enableSpotlightIntegration)
      ..writeByte(15)
      ..write(obj.showMenuBarIcon)
      ..writeByte(16)
      ..write(obj.dateFormat)
      ..writeByte(17)
      ..write(obj.timeFormat)
      ..writeByte(18)
      ..write(obj.windowWidth)
      ..writeByte(19)
      ..write(obj.windowHeight)
      ..writeByte(20)
      ..write(obj.sidebarWidth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskViewModeAdapter extends TypeAdapter<TaskViewMode> {
  @override
  final int typeId = 9;

  @override
  TaskViewMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskViewMode.list;
      case 1:
        return TaskViewMode.kanban;
      case 2:
        return TaskViewMode.calendar;
      case 3:
        return TaskViewMode.timeline;
      default:
        return TaskViewMode.list;
    }
  }

  @override
  void write(BinaryWriter writer, TaskViewMode obj) {
    switch (obj) {
      case TaskViewMode.list:
        writer.writeByte(0);
        break;
      case TaskViewMode.kanban:
        writer.writeByte(1);
        break;
      case TaskViewMode.calendar:
        writer.writeByte(2);
        break;
      case TaskViewMode.timeline:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskViewModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskSortOrderAdapter extends TypeAdapter<TaskSortOrder> {
  @override
  final int typeId = 10;

  @override
  TaskSortOrder read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskSortOrder.dueDate;
      case 1:
        return TaskSortOrder.priority;
      case 2:
        return TaskSortOrder.created;
      case 3:
        return TaskSortOrder.modified;
      case 4:
        return TaskSortOrder.alphabetical;
      case 5:
        return TaskSortOrder.manual;
      default:
        return TaskSortOrder.dueDate;
    }
  }

  @override
  void write(BinaryWriter writer, TaskSortOrder obj) {
    switch (obj) {
      case TaskSortOrder.dueDate:
        writer.writeByte(0);
        break;
      case TaskSortOrder.priority:
        writer.writeByte(1);
        break;
      case TaskSortOrder.created:
        writer.writeByte(2);
        break;
      case TaskSortOrder.modified:
        writer.writeByte(3);
        break;
      case TaskSortOrder.alphabetical:
        writer.writeByte(4);
        break;
      case TaskSortOrder.manual:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSortOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

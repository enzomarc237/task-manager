import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _tasksBoxName = 'tasks';
  static const String _projectsBoxName = 'projects';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  late Box<Task> _tasksBox;
  late Box<Project> _projectsBox;
  late Box<AppSettings> _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(SubtaskAdapter());
    Hive.registerAdapter(RecurrencePatternAdapter());
    Hive.registerAdapter(RecurrenceTypeAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(ProjectStatusAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(TaskViewModeAdapter());
    Hive.registerAdapter(TaskSortOrderAdapter());

    // Open boxes
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _projectsBox = await Hive.openBox<Project>(_projectsBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
  }

  // Task operations
  Future<List<Task>> loadTasks() async {
    return _tasksBox.values.toList();
  }

  Future<void> saveTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  Future<Task?> getTask(String taskId) async {
    return _tasksBox.get(taskId);
  }

  // Project operations
  Future<List<Project>> loadProjects() async {
    return _projectsBox.values.toList();
  }

  Future<void> saveProject(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  Future<void> deleteProject(String projectId) async {
    await _projectsBox.delete(projectId);
  }

  Future<Project?> getProject(String projectId) async {
    return _projectsBox.get(projectId);
  }

  // Settings operations
  Future<AppSettings> loadSettings() async {
    return _settingsBox.get(_settingsKey) ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    final tasks = await loadTasks();
    final projects = await loadProjects();
    final settings = await loadSettings();

    return {
      'tasks': tasks.map((t) => _taskToJson(t)).toList(),
      'projects': projects.map((p) => _projectToJson(p)).toList(),
      'settings': _settingsToJson(settings),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await _tasksBox.clear();
    await _projectsBox.clear();

    // Import projects first
    if (data['projects'] != null) {
      for (final projectData in data['projects']) {
        final project = _projectFromJson(projectData);
        await saveProject(project);
      }
    }

    // Import tasks
    if (data['tasks'] != null) {
      for (final taskData in data['tasks']) {
        final task = _taskFromJson(taskData);
        await saveTask(task);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      final settings = _settingsFromJson(data['settings']);
      await saveSettings(settings);
    }
  }

  // Search operations
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await loadTasks();
    final lowerQuery = query.toLowerCase();
    
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
             task.description.toLowerCase().contains(lowerQuery) ||
             task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<List<Task>> getTasksByProject(String projectId) async {
    final tasks = await loadTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<List<Task>> getTasksByTag(String tag) async {
    final tasks = await loadTasks();
    return tasks.where((task) => task.tags.contains(tag)).toList();
  }

  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final tasks = await loadTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final tasks = await loadTasks();
    return tasks.where((task) => task.status == status).toList();
  }

  Future<List<Task>> getTasksDueToday() async {
    final tasks = await loadTasks();
    final today = DateTime.now();
    
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = task.dueDate!;
      return dueDate.year == today.year &&
             dueDate.month == today.month &&
             dueDate.day == today.day;
    }).toList();
  }

  Future<List<Task>> getOverdueTasks() async {
    final tasks = await loadTasks();
    final now = DateTime.now();
    
    return tasks.where((task) {
      return task.dueDate != null &&
             task.dueDate!.isBefore(now) &&
             !task.isCompleted;
    }).toList();
  }

  // Statistics
  Future<Map<String, int>> getTaskStatistics() async {
    final tasks = await loadTasks();
    
    return {
      'total': tasks.length,
      'completed': tasks.where((t) => t.isCompleted).length,
      'pending': tasks.where((t) => !t.isCompleted).length,
      'overdue': tasks.where((t) => t.isOverdue).length,
      'high_priority': tasks.where((t) => t.priority == TaskPriority.high).length,
      'urgent': tasks.where((t) => t.priority == TaskPriority.urgent).length,
    };
  }

  // Cleanup operations
  Future<void> cleanupCompletedTasks({int daysOld = 30}) async {
    final tasks = await loadTasks();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    final tasksToDelete = tasks.where((task) =>
      task.isCompleted &&
      task.completedAt != null &&
      task.completedAt!.isBefore(cutoffDate)
    ).toList();

    for (final task in tasksToDelete) {
      await deleteTask(task.id);
    }
  }

  Future<void> archiveCompletedTasks() async {
    final tasks = await loadTasks();
    
    for (final task in tasks.where((t) => t.isCompleted)) {
      task.isArchived = true;
      await saveTask(task);
    }
  }

  // Private helper methods for JSON serialization
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority.index,
      'status': task.status.index,
      'createdAt': task.createdAt.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'estimatedEffort': task.estimatedEffort,
      'actualEffort': task.actualEffort,
      'projectId': task.projectId,
      'tags': task.tags,
      'contexts': task.contexts,
      'subtasks': task.subtasks.map((s) => {
        'id': s.id,
        'title': s.title,
        'isCompleted': s.isCompleted,
        'createdAt': s.createdAt.toIso8601String(),
        'completedAt': s.completedAt?.toIso8601String(),
      }).toList(),
      'parentTaskId': task.parentTaskId,
      'isRecurring': task.isRecurring,
      'sortOrder': task.sortOrder,
      'lastModified': task.lastModified?.toIso8601String(),
      'isArchived': task.isArchived,
    };
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      priority: TaskPriority.values[json['priority'] ?? 1],
      status: TaskStatus.values[json['status'] ?? 0],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      estimatedEffort: json['estimatedEffort'] ?? 0,
      actualEffort: json['actualEffort'] ?? 0,
      projectId: json['projectId'],
      tags: List<String>.from(json['tags'] ?? []),
      contexts: List<String>.from(json['contexts'] ?? []),
      subtasks: (json['subtasks'] as List?)?.map((s) => Subtask(
        id: s['id'],
        title: s['title'],
        isCompleted: s['isCompleted'] ?? false,
        createdAt: DateTime.parse(s['createdAt']),
        completedAt: s['completedAt'] != null ? DateTime.parse(s['completedAt']) : null,
      )).toList() ?? [],
      parentTaskId: json['parentTaskId'],
      isRecurring: json['isRecurring'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      isArchived: json['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> _projectToJson(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'colorValue': project.colorValue,
      'iconName': project.iconName,
      'createdAt': project.createdAt.toIso8601String(),
      'lastModified': project.lastModified?.toIso8601String(),
      'isArchived': project.isArchived,
      'sortOrder': project.sortOrder,
      'dueDate': project.dueDate?.toIso8601String(),
      'status': project.status.index,
    };
  }

  Project _projectFromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      isArchived: json['isArchived'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: ProjectStatus.values[json['status'] ?? 0],
    )..colorValue = json['colorValue'] ?? 0xFF2196F3;
  }

  Map<String, dynamic> _settingsToJson(AppSettings settings) {
    return {
      'themeMode': settings.themeMode.index,
      'defaultViewMode': settings.defaultViewMode.index,
      'showCompletedTasks': settings.showCompletedTasks,
      'enableNotifications': settings.enableNotifications,
      'defaultReminderMinutes': settings.defaultReminderMinutes,
      'enableNaturalLanguageEntry': settings.enableNaturalLanguageEntry,
      'enableKeyboardShortcuts': settings.enableKeyboardShortcuts,
      'enableDragAndDrop': settings.enableDragAndDrop,
      'defaultSortOrder': settings.defaultSortOrder.index,
      'groupByProject': settings.groupByProject,
      'showSubtaskProgress': settings.showSubtaskProgress,
      'enableFocusMode': settings.enableFocusMode,
      'focusModeMaxTasks': settings.focusModeMaxTasks,
      'enableiCloudSync': settings.enableiCloudSync,
      'enableSpotlightIntegration': settings.enableSpotlightIntegration,
      'showMenuBarIcon': settings.showMenuBarIcon,
      'dateFormat': settings.dateFormat,
      'timeFormat': settings.timeFormat,
      'windowWidth': settings.windowWidth,
      'windowHeight': settings.windowHeight,
      'sidebarWidth': settings.sidebarWidth,
    };
  }

  AppSettings _settingsFromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      defaultViewMode: TaskViewMode.values[json['defaultViewMode'] ?? 0],
      showCompletedTasks: json['showCompletedTasks'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      defaultReminderMinutes: json['defaultReminderMinutes'] ?? 15,
      enableNaturalLanguageEntry: json['enableNaturalLanguageEntry'] ?? true,
      enableKeyboardShortcuts: json['enableKeyboardShortcuts'] ?? true,
      enableDragAndDrop: json['enableDragAndDrop'] ?? true,
      defaultSortOrder: TaskSortOrder.values[json['defaultSortOrder'] ?? 0],
      groupByProject: json['groupByProject'] ?? false,
      showSubtaskProgress: json['showSubtaskProgress'] ?? true,
      enableFocusMode: json['enableFocusMode'] ?? false,
      focusModeMaxTasks: json['focusModeMaxTasks'] ?? 3,
      enableiCloudSync: json['enableiCloudSync'] ?? false,
      enableSpotlightIntegration: json['enableSpotlightIntegration'] ?? true,
      showMenuBarIcon: json['showMenuBarIcon'] ?? true,
      dateFormat: json['dateFormat'] ?? 'MMM d, yyyy',
      timeFormat: json['timeFormat'] ?? 'h:mm a',
      windowWidth: json['windowWidth']?.toDouble() ?? 1200.0,
      windowHeight: json['windowHeight']?.toDouble() ?? 800.0,
      sidebarWidth: json['sidebarWidth']?.toDouble() ?? 280.0,
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  
  List<Task> _tasks = [];
  List<Project> _projects = [];
  String _searchQuery = '';
  TaskPriority? _filterPriority;
  TaskStatus? _filterStatus;
  String? _filterProject;
  List<String> _filterTags = [];
  bool _showCompleted = false;

  TaskProvider(this._storageService, this._notificationService) {
    _loadData();
  }

  // Getters
  List<Task> get tasks => _getFilteredTasks();
  List<Task> get allTasks => _tasks;
  List<Project> get projects => _projects;
  String get searchQuery => _searchQuery;
  TaskPriority? get filterPriority => _filterPriority;
  TaskStatus? get filterStatus => _filterStatus;
  String? get filterProject => _filterProject;
  List<String> get filterTags => _filterTags;
  bool get showCompleted => _showCompleted;

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;
  int get todayTasks => _tasks.where((t) => 
    t.dueDate != null && 
    _isSameDay(t.dueDate!, DateTime.now()) && 
    !t.isCompleted
  ).length;

  // Task Management
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _storageService.saveTask(task);
    
    // Schedule notification if due date is set
    if (task.dueDate != null) {
      await _notificationService.scheduleTaskReminder(task);
    }
    
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _storageService.saveTask(task);
      
      // Update notification
      if (task.dueDate != null) {
        await _notificationService.scheduleTaskReminder(task);
      } else {
        await _notificationService.cancelTaskReminder(task.id);
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    
    // Delete subtasks if any
    _tasks.removeWhere((t) => t.parentTaskId == taskId);
    
    await _storageService.deleteTask(taskId);
    await _notificationService.cancelTaskReminder(taskId);
    
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    if (task.isCompleted) {
      task.markIncomplete();
    } else {
      task.markCompleted();
      
      // Handle recurring tasks
      if (task.isRecurring && task.recurrencePattern != null) {
        final nextTask = _createRecurringTask(task);
        await addTask(nextTask);
      }
    }
    
    await updateTask(task);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final subtask = task.subtasks.firstWhere((s) => s.id == subtaskId);
    subtask.toggle();
    
    await updateTask(task);
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final filteredTasks = _getFilteredTasks();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final task = filteredTasks.removeAt(oldIndex);
    filteredTasks.insert(newIndex, task);
    
    // Update sort orders
    for (int i = 0; i < filteredTasks.length; i++) {
      filteredTasks[i].sortOrder = i;
      await _storageService.saveTask(filteredTasks[i]);
    }
    
    notifyListeners();
  }

  // Project Management
  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _storageService.saveProject(project);
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await _storageService.saveProject(project);
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    
    // Remove project reference from tasks
    for (final task in _tasks.where((t) => t.projectId == projectId)) {
      task.projectId = null;
      await _storageService.saveTask(task);
    }
    
    await _storageService.deleteProject(projectId);
    notifyListeners();
  }

  // Filtering and Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterPriority(TaskPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterProject(String? projectId) {
    _filterProject = projectId;
    notifyListeners();
  }

  void setFilterTags(List<String> tags) {
    _filterTags = tags;
    notifyListeners();
  }

  void setShowCompleted(bool show) {
    _showCompleted = show;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterPriority = null;
    _filterStatus = null;
    _filterProject = null;
    _filterTags.clear();
    notifyListeners();
  }

  // Natural Language Processing
  Task parseNaturalLanguageTask(String input) {
    // Simple NLP parsing - can be enhanced with more sophisticated algorithms
    String title = input;
    TaskPriority priority = TaskPriority.medium;
    DateTime? dueDate;
    List<String> tags = [];
    String? projectId;

    // Extract priority keywords
    if (input.toLowerCase().contains('urgent') || input.toLowerCase().contains('asap')) {
      priority = TaskPriority.urgent;
      title = title.replaceAll(RegExp(r'\b(urgent|asap)\b', caseSensitive: false), '').trim();
    } else if (input.toLowerCase().contains('high priority')) {
      priority = TaskPriority.high;
      title = title.replaceAll(RegExp(r'\bhigh priority\b', caseSensitive: false), '').trim();
    } else if (input.toLowerCase().contains('low priority')) {
      priority = TaskPriority.low;
      title = title.replaceAll(RegExp(r'\blow priority\b', caseSensitive: false), '').trim();
    }

    // Extract due date keywords
    final now = DateTime.now();
    if (input.toLowerCase().contains('today')) {
      dueDate = DateTime(now.year, now.month, now.day, 23, 59);
      title = title.replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '').trim();
    } else if (input.toLowerCase().contains('tomorrow')) {
      final tomorrow = now.add(const Duration(days: 1));
      dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
      title = title.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '').trim();
    } else if (input.toLowerCase().contains('next week')) {
      final nextWeek = now.add(const Duration(days: 7));
      dueDate = DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 23, 59);
      title = title.replaceAll(RegExp(r'\bnext week\b', caseSensitive: false), '').trim();
    }

    // Extract tags (words starting with #)
    final tagRegex = RegExp(r'#(\w+)');
    final tagMatches = tagRegex.allMatches(input);
    for (final match in tagMatches) {
      tags.add(match.group(1)!);
    }
    title = title.replaceAll(tagRegex, '').trim();

    // Extract project references (words starting with @)
    final projectRegex = RegExp(r'@(\w+)');
    final projectMatch = projectRegex.firstMatch(input);
    if (projectMatch != null) {
      final projectName = projectMatch.group(1)!;
      final project = _projects.firstWhere(
        (p) => p.name.toLowerCase() == projectName.toLowerCase(),
        orElse: () => Project(name: ''),
      );
      if (project.name.isNotEmpty) {
        projectId = project.id;
      }
      title = title.replaceAll(projectRegex, '').trim();
    }

    // Clean up title
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    return Task(
      title: title,
      priority: priority,
      dueDate: dueDate,
      tags: tags,
      projectId: projectId,
    );
  }

  // Private Methods
  Future<void> _loadData() async {
    _tasks = await _storageService.loadTasks();
    _projects = await _storageService.loadProjects();
    notifyListeners();
  }

  List<Task> _getFilteredTasks() {
    var filtered = _tasks.where((task) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !task.description.toLowerCase().contains(query) &&
            !task.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Priority filter
      if (_filterPriority != null && task.priority != _filterPriority) {
        return false;
      }

      // Status filter
      if (_filterStatus != null && task.status != _filterStatus) {
        return false;
      }

      // Project filter
      if (_filterProject != null && task.projectId != _filterProject) {
        return false;
      }

      // Tags filter
      if (_filterTags.isNotEmpty && 
          !_filterTags.every((tag) => task.tags.contains(tag))) {
        return false;
      }

      // Completed tasks filter
      if (!_showCompleted && task.isCompleted) {
        return false;
      }

      return true;
    }).toList();

    // Sort tasks
    filtered.sort((a, b) {
      // Completed tasks go to bottom
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Then by priority (urgent first)
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }

      // Then by due date
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // Finally by creation date
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  Task _createRecurringTask(Task originalTask) {
    DateTime? nextDueDate;
    
    if (originalTask.dueDate != null && originalTask.recurrencePattern != null) {
      final pattern = originalTask.recurrencePattern!;
      final currentDue = originalTask.dueDate!;
      
      switch (pattern.type) {
        case RecurrenceType.daily:
          nextDueDate = currentDue.add(Duration(days: pattern.interval));
          break;
        case RecurrenceType.weekly:
          nextDueDate = currentDue.add(Duration(days: 7 * pattern.interval));
          break;
        case RecurrenceType.monthly:
          nextDueDate = DateTime(
            currentDue.year,
            currentDue.month + pattern.interval,
            currentDue.day,
            currentDue.hour,
            currentDue.minute,
          );
          break;
        case RecurrenceType.yearly:
          nextDueDate = DateTime(
            currentDue.year + pattern.interval,
            currentDue.month,
            currentDue.day,
            currentDue.hour,
            currentDue.minute,
          );
          break;
      }
    }

    return originalTask.copyWith(
      status: TaskStatus.todo,
      dueDate: nextDueDate,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Get tasks for specific views
  List<Task> getTasksForToday() {
    final today = DateTime.now();
    return _tasks.where((task) =>
      !task.isCompleted &&
      task.dueDate != null &&
      _isSameDay(task.dueDate!, today)
    ).toList();
  }

  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> getOverdueTasks() {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (final task in _tasks) {
      allTags.addAll(task.tags);
    }
    return allTags.toList()..sort();
  }

  List<String> getAllContexts() {
    final allContexts = <String>{};
    for (final task in _tasks) {
      allContexts.addAll(task.contexts);
    }
    return allContexts.toList()..sort();
  }
}
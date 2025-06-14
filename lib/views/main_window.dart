import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_list_view.dart';
import '../widgets/task_detail_view.dart';
import '../widgets/toolbar.dart';
import '../widgets/quick_entry.dart';
import '../models/task.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  Task? _selectedTask;
  bool _showDetailView = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        maxWidth: 300,
        shownByDefault: true,
        builder: (context, scrollController) {
          return TaskSidebar(
            onSelectionChanged: _handleSidebarSelection,
          );
        },
      ),
      child: MacosScaffold(
        key: _scaffoldKey,
        toolBar: TaskToolbar(
          onNewTask: _showNewTaskDialog,
          onSearch: _handleSearch,
          onViewModeChanged: _handleViewModeChanged,
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Quick Entry Bar
                  const QuickEntryBar(),
                  
                  // Main Content
                  Expanded(
                    child: Row(
                      children: [
                        // Task List
                        Expanded(
                          flex: _showDetailView ? 1 : 2,
                          child: TaskListView(
                            selectedTask: _selectedTask,
                            onTaskSelected: _handleTaskSelection,
                            onTaskToggled: _handleTaskToggle,
                          ),
                        ),
                        
                        // Task Detail View
                        if (_showDetailView && _selectedTask != null)
                          Expanded(
                            flex: 1,
                            child: TaskDetailView(
                              task: _selectedTask!,
                              onTaskUpdated: _handleTaskUpdate,
                              onClose: () {
                                setState(() {
                                  _showDetailView = false;
                                  _selectedTask = null;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleSidebarSelection(String? selection) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // Clear current filters
    taskProvider.clearFilters();
    
    switch (selection) {
      case 'inbox':
        // Show all tasks
        break;
      case 'today':
        // Filter tasks due today
        break;
      case 'upcoming':
        // Filter upcoming tasks
        break;
      case 'completed':
        taskProvider.setShowCompleted(true);
        taskProvider.setFilterStatus(TaskStatus.completed);
        break;
      case 'overdue':
        // Filter overdue tasks
        break;
      default:
        if (selection != null && selection.startsWith('project:')) {
          final projectId = selection.substring(8);
          taskProvider.setFilterProject(projectId);
        }
    }
  }

  void _handleTaskSelection(Task task) {
    setState(() {
      _selectedTask = task;
      _showDetailView = true;
    });
  }

  void _handleTaskToggle(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.toggleTaskCompletion(task.id);
  }

  void _handleTaskUpdate(Task updatedTask) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.updateTask(updatedTask);
    
    setState(() {
      _selectedTask = updatedTask;
    });
  }

  void _showNewTaskDialog() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => const NewTaskDialog(),
    );
  }

  void _handleSearch(String query) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.setSearchQuery(query);
  }

  void _handleViewModeChanged(String viewMode) {
    // TODO: Implement view mode changes (list, kanban, calendar)
  }
}

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({super.key});

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _selectedProjectId;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(Icons.add_task),
      title: const Text('New Task'),
      message: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MacosTextField(
              controller: _titleController,
              placeholder: 'Task title',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            MacosTextField(
              controller: _descriptionController,
              placeholder: 'Description (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MacosPopupButton<TaskPriority>(
                    value: _priority,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                        });
                      }
                    },
                    items: TaskPriority.values.map((priority) {
                      return MacosPopupMenuItem(
                        value: priority,
                        child: Text(_priorityToString(priority)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                MacosIconButton(
                  icon: const MacosIcon(Icons.calendar_today),
                  onPressed: _selectDueDate,
                ),
              ],
            ),
            if (_dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Due: ${_formatDate(_dueDate!)}',
                  style: MacosTheme.of(context).typography.caption1,
                ),
              ),
          ],
        ),
      ),
      primaryButton: PushButton(
        buttonSize: ButtonSize.large,
        onPressed: _createTask,
        child: const Text('Create'),
      ),
      secondaryButton: PushButton(
        buttonSize: ButtonSize.large,
        secondary: true,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showMacosDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty) {
      return;
    }

    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      projectId: _selectedProjectId,
    );

    Provider.of<TaskProvider>(context, listen: false).addTask(task);
    Navigator.of(context).pop();
  }

  String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import 'task_item.dart';

class TaskListView extends StatefulWidget {
  final Task? selectedTask;
  final Function(Task) onTaskSelected;
  final Function(Task) onTaskToggled;

  const TaskListView({
    super.key,
    this.selectedTask,
    required this.onTaskSelected,
    required this.onTaskToggled,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        
        if (tasks.isEmpty) {
          return _buildEmptyState(taskProvider);
        }

        return Column(
          children: [
            // Header with task count and filters
            _buildHeader(taskProvider),
            
            // Task list
            Expanded(
              child: ReorderableListView.builder(
                itemCount: tasks.length,
                onReorder: (oldIndex, newIndex) {
                  taskProvider.reorderTasks(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isSelected = widget.selectedTask?.id == task.id;
                  
                  return TaskItem(
                    key: ValueKey(task.id),
                    task: task,
                    isSelected: isSelected,
                    onTap: () => widget.onTaskSelected(task),
                    onToggle: () => widget.onTaskToggled(task),
                    onEdit: () => _editTask(task),
                    onDelete: () => _deleteTask(task),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(TaskProvider taskProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
    final hasFilters = taskProvider.searchQuery.isNotEmpty ||
                      taskProvider.filterPriority != null ||
                      taskProvider.filterStatus != null ||
                      taskProvider.filterProject != null ||
                      taskProvider.filterTags.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Task count
          Text(
            '$totalTasks ${totalTasks == 1 ? 'task' : 'tasks'}',
            style: MacosTheme.of(context).typography.headline,
          ),
          
          if (completedTasks > 0) ...[
            const SizedBox(width: 8),
            Text(
              '($completedTasks completed)',
              style: MacosTheme.of(context).typography.caption1?.copyWith(
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
          
          const Spacer(),
          
          // Active filters indicator
          if (hasFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MacosIcon(
                    Icons.filter_list,
                    size: 14,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filtered',
                    style: MacosTheme.of(context).typography.caption1?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MacosIconButton(
              icon: const MacosIcon(Icons.clear, size: 16),
              onPressed: taskProvider.clearFilters,
            ),
          ],
          
          // Sort options
          MacosPopupButton<String>(
            value: 'default',
            onChanged: (value) => _handleSortChange(value, taskProvider),
            items: const [
              MacosPopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    MacosIcon(Icons.sort, size: 16),
                    SizedBox(width: 8),
                    Text('Sort by'),
                  ],
                ),
              ),
              MacosPopupMenuItem(
                value: 'priority',
                child: Text('Priority'),
              ),
              MacosPopupMenuItem(
                value: 'due_date',
                child: Text('Due Date'),
              ),
              MacosPopupMenuItem(
                value: 'created',
                child: Text('Created'),
              ),
              MacosPopupMenuItem(
                value: 'alphabetical',
                child: Text('Alphabetical'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TaskProvider taskProvider) {
    final hasFilters = taskProvider.searchQuery.isNotEmpty ||
                      taskProvider.filterPriority != null ||
                      taskProvider.filterStatus != null ||
                      taskProvider.filterProject != null ||
                      taskProvider.filterTags.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MacosIcon(
            hasFilters ? Icons.search_off : Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No tasks match your filters' : 'No tasks yet',
            style: MacosTheme.of(context).typography.title2?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters 
                ? 'Try adjusting your search or filters'
                : 'Create your first task to get started',
            style: MacosTheme.of(context).typography.body?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (hasFilters)
            PushButton(
              buttonSize: ButtonSize.large,
              onPressed: taskProvider.clearFilters,
              child: const Text('Clear Filters'),
            )
          else
            PushButton(
              buttonSize: ButtonSize.large,
              onPressed: _showNewTaskDialog,
              child: const Text('Create First Task'),
            ),
        ],
      ),
    );
  }

  void _handleSortChange(String? value, TaskProvider taskProvider) {
    // TODO: Implement sorting logic
    if (value == null) return;
    
    switch (value) {
      case 'priority':
        // Sort by priority
        break;
      case 'due_date':
        // Sort by due date
        break;
      case 'created':
        // Sort by creation date
        break;
      case 'alphabetical':
        // Sort alphabetically
        break;
    }
  }

  void _editTask(Task task) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => EditTaskDialog(task: task),
    );
  }

  void _deleteTask(Task task) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const MacosIcon(Icons.delete),
        title: const Text('Delete Task'),
        message: Text('Are you sure you want to delete "${task.title}"?'),
        primaryButton: PushButton(
          buttonSize: ButtonSize.large,
          onPressed: () {
            Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
        secondaryButton: PushButton(
          buttonSize: ButtonSize.large,
          secondary: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showNewTaskDialog() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => const NewTaskDialog(),
    );
  }
}

class EditTaskDialog extends StatefulWidget {
  final Task task;

  const EditTaskDialog({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
    _selectedProjectId = widget.task.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(Icons.edit),
      title: const Text('Edit Task'),
      message: SizedBox(
        width: 400,
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due: ${_formatDate(_dueDate!)}',
                        style: MacosTheme.of(context).typography.caption1,
                      ),
                    ),
                    MacosIconButton(
                      icon: const MacosIcon(Icons.clear, size: 16),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      primaryButton: PushButton(
        buttonSize: ButtonSize.large,
        onPressed: _updateTask,
        child: const Text('Update'),
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
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _updateTask() {
    if (_titleController.text.trim().isEmpty) {
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      projectId: _selectedProjectId,
    );

    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
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
      message: SizedBox(
        width: 400,
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
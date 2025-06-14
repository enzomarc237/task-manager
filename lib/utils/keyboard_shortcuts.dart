import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class KeyboardShortcutHandler {
  static KeyEventResult handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isMetaPressed = event.logicalKey == LogicalKeyboardKey.metaLeft ||
                         event.logicalKey == LogicalKeyboardKey.metaRight ||
                         HardwareKeyboard.instance.isMetaPressed;
    final isShiftPressed = event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                          event.logicalKey == LogicalKeyboardKey.shiftRight ||
                          HardwareKeyboard.instance.isShiftPressed;
    final isControlPressed = event.logicalKey == LogicalKeyboardKey.controlLeft ||
                            event.logicalKey == LogicalKeyboardKey.controlRight ||
                            HardwareKeyboard.instance.isControlPressed;

    // Command/Ctrl + N: New Task
    if ((isMetaPressed || isControlPressed) && event.logicalKey == LogicalKeyboardKey.keyN) {
      _showNewTaskDialog(context);
      return KeyEventResult.handled;
    }

    // Command/Ctrl + F: Focus Search
    if ((isMetaPressed || isControlPressed) && event.logicalKey == LogicalKeyboardKey.keyF) {
      _focusSearch(context);
      return KeyEventResult.handled;
    }

    // Command/Ctrl + Shift + F: Clear Filters
    if ((isMetaPressed || isControlPressed) && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
      taskProvider.clearFilters();
      return KeyEventResult.handled;
    }

    // Command/Ctrl + 1-4: Filter by Priority
    if (isMetaPressed || isControlPressed) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.digit1:
          taskProvider.setFilterPriority(TaskPriority.low);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.digit2:
          taskProvider.setFilterPriority(TaskPriority.medium);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.digit3:
          taskProvider.setFilterPriority(TaskPriority.high);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.digit4:
          taskProvider.setFilterPriority(TaskPriority.urgent);
          return KeyEventResult.handled;
      }
    }

    // Command/Ctrl + Shift + C: Show Completed Tasks
    if ((isMetaPressed || isControlPressed) && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
      taskProvider.setShowCompleted(!taskProvider.showCompleted);
      return KeyEventResult.handled;
    }

    // Command/Ctrl + R: Refresh
    if ((isMetaPressed || isControlPressed) && event.logicalKey == LogicalKeyboardKey.keyR) {
      // Refresh data
      return KeyEventResult.handled;
    }

    // Command/Ctrl + Comma: Open Preferences
    if ((isMetaPressed || isControlPressed) && event.logicalKey == LogicalKeyboardKey.comma) {
      _showPreferences(context);
      return KeyEventResult.handled;
    }

    // Escape: Clear Selection/Close Dialogs
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }

    // Delete/Backspace: Delete Selected Task
    if (event.logicalKey == LogicalKeyboardKey.delete || 
        event.logicalKey == LogicalKeyboardKey.backspace) {
      // TODO: Implement task selection and deletion
      return KeyEventResult.handled;
    }

    // Space: Toggle Task Completion
    if (event.logicalKey == LogicalKeyboardKey.space) {
      // TODO: Implement task selection and toggle
      return KeyEventResult.handled;
    }

    // Enter: Edit Selected Task
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      // TODO: Implement task selection and editing
      return KeyEventResult.handled;
    }

    // Arrow Keys: Navigate Tasks
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // TODO: Implement task navigation
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  static void _showNewTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NewTaskDialog(),
    );
  }

  static void _focusSearch(BuildContext context) {
    // TODO: Focus search field
  }

  static void _showPreferences(BuildContext context) {
    // TODO: Show preferences dialog
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
    return AlertDialog(
      title: const Text('New Task'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_priorityToString(priority)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(_dueDate == null 
                    ? 'No due date' 
                    : 'Due: ${_dueDate!.toString().split(' ')[0]}'
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
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
                  },
                  child: const Text('Set Due Date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty) return;

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
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

// Keyboard shortcut help overlay
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keyboard Shortcuts'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShortcutSection('General', [
                _buildShortcut('⌘N', 'New Task'),
                _buildShortcut('⌘F', 'Search Tasks'),
                _buildShortcut('⌘⇧F', 'Clear Filters'),
                _buildShortcut('⌘R', 'Refresh'),
                _buildShortcut('⌘,', 'Preferences'),
                _buildShortcut('Esc', 'Close Dialog'),
              ]),
              const SizedBox(height: 16),
              _buildShortcutSection('Filtering', [
                _buildShortcut('⌘1', 'Filter Low Priority'),
                _buildShortcut('⌘2', 'Filter Medium Priority'),
                _buildShortcut('⌘3', 'Filter High Priority'),
                _buildShortcut('⌘4', 'Filter Urgent Priority'),
                _buildShortcut('⌘⇧C', 'Toggle Completed Tasks'),
              ]),
              const SizedBox(height: 16),
              _buildShortcutSection('Task Management', [
                _buildShortcut('Space', 'Toggle Task Completion'),
                _buildShortcut('Enter', 'Edit Selected Task'),
                _buildShortcut('Delete', 'Delete Selected Task'),
                _buildShortcut('↑/↓', 'Navigate Tasks'),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildShortcutSection(String title, List<Widget> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...shortcuts,
      ],
    );
  }

  Widget _buildShortcut(String keys, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
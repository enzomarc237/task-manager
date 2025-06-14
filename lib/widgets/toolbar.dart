import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/theme.dart';

class TaskToolbar extends StatefulWidget implements ObstructingPreferredSizeWidget {
  final VoidCallback onNewTask;
  final Function(String) onSearch;
  final Function(String) onViewModeChanged;

  const TaskToolbar({
    super.key,
    required this.onNewTask,
    required this.onSearch,
    required this.onViewModeChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  State<TaskToolbar> createState() => _TaskToolbarState();
}

class _TaskToolbarState extends State<TaskToolbar> {
  final _searchController = TextEditingController();
  String _currentViewMode = 'list';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: const Text('TaskManager'),
      titleWidth: 150,
      leading: MacosIconButton(
        icon: const MacosIcon(Icons.add),
        onPressed: widget.onNewTask,
      ),
      actions: [
        // Search Field
        SizedBox(
          width: 200,
          child: MacosSearchField(
            controller: _searchController,
            placeholder: 'Search tasks...',
            onChanged: widget.onSearch,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // View Mode Selector
        MacosSegmentedControl<String>(
          groupValue: _currentViewMode,
          onValueChanged: (value) {
            if (value != null) {
              setState(() {
                _currentViewMode = value;
              });
              widget.onViewModeChanged(value);
            }
          },
          children: const {
            'list': MacosIcon(Icons.list),
            'kanban': MacosIcon(Icons.view_column),
            'calendar': MacosIcon(Icons.calendar_today),
          },
        ),
        
        const SizedBox(width: 12),
        
        // Filter Menu
        Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return MacosPopupButton<String>(
              value: 'all',
              onChanged: (value) => _handleFilterChange(value, taskProvider),
              items: [
                const MacosPopupMenuItem(
                  value: 'all',
                  child: Text('All Tasks'),
                ),
                const MacosPopupMenuItem(
                  value: 'urgent',
                  child: Row(
                    children: [
                      Icon(Icons.priority_high, color: AppTheme.urgentColor, size: 16),
                      SizedBox(width: 8),
                      Text('Urgent'),
                    ],
                  ),
                ),
                const MacosPopupMenuItem(
                  value: 'high',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: AppTheme.highColor, size: 16),
                      SizedBox(width: 8),
                      Text('High Priority'),
                    ],
                  ),
                ),
                const MacosPopupMenuItem(
                  value: 'medium',
                  child: Row(
                    children: [
                      Icon(Icons.remove, color: AppTheme.mediumColor, size: 16),
                      SizedBox(width: 8),
                      Text('Medium Priority'),
                    ],
                  ),
                ),
                const MacosPopupMenuItem(
                  value: 'low',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, color: AppTheme.lowColor, size: 16),
                      SizedBox(width: 8),
                      Text('Low Priority'),
                    ],
                  ),
                ),
                const MacosPopupMenuItem(
                  value: 'divider',
                  child: Divider(),
                ),
                const MacosPopupMenuItem(
                  value: 'completed',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
                      SizedBox(width: 8),
                      Text('Show Completed'),
                    ],
                  ),
                ),
                const MacosPopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear, size: 16),
                      SizedBox(width: 8),
                      Text('Clear Filters'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(width: 12),
        
        // More Actions Menu
        MacosPopupButton<String>(
          value: 'more',
          onChanged: _handleMoreActions,
          items: const [
            MacosPopupMenuItem(
              value: 'more',
              child: MacosIcon(Icons.more_horiz),
            ),
            MacosPopupMenuItem(
              value: 'preferences',
              child: Row(
                children: [
                  MacosIcon(Icons.settings, size: 16),
                  SizedBox(width: 8),
                  Text('Preferences...'),
                ],
              ),
            ),
            MacosPopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  MacosIcon(Icons.download, size: 16),
                  SizedBox(width: 8),
                  Text('Export Data'),
                ],
              ),
            ),
            MacosPopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  MacosIcon(Icons.upload, size: 16),
                  SizedBox(width: 8),
                  Text('Import Data'),
                ],
              ),
            ),
            MacosPopupMenuItem(
              value: 'divider',
              child: Divider(),
            ),
            MacosPopupMenuItem(
              value: 'shortcuts',
              child: Row(
                children: [
                  MacosIcon(Icons.keyboard, size: 16),
                  SizedBox(width: 8),
                  Text('Keyboard Shortcuts'),
                ],
              ),
            ),
            MacosPopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  MacosIcon(Icons.info, size: 16),
                  SizedBox(width: 8),
                  Text('About TaskManager'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleFilterChange(String? value, TaskProvider taskProvider) {
    if (value == null) return;
    
    switch (value) {
      case 'all':
        taskProvider.clearFilters();
        break;
      case 'urgent':
        taskProvider.setFilterPriority(TaskPriority.urgent);
        break;
      case 'high':
        taskProvider.setFilterPriority(TaskPriority.high);
        break;
      case 'medium':
        taskProvider.setFilterPriority(TaskPriority.medium);
        break;
      case 'low':
        taskProvider.setFilterPriority(TaskPriority.low);
        break;
      case 'completed':
        taskProvider.setShowCompleted(!taskProvider.showCompleted);
        break;
      case 'clear':
        taskProvider.clearFilters();
        break;
    }
  }

  void _handleMoreActions(String? value) {
    if (value == null || value == 'more') return;
    
    switch (value) {
      case 'preferences':
        _showPreferences();
        break;
      case 'export':
        _exportData();
        break;
      case 'import':
        _importData();
        break;
      case 'shortcuts':
        _showKeyboardShortcuts();
        break;
      case 'about':
        _showAbout();
        break;
    }
  }

  void _showPreferences() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => const PreferencesDialog(),
    );
  }

  void _exportData() {
    // TODO: Implement data export
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const MacosIcon(Icons.download),
        title: const Text('Export Data'),
        message: const Text('Export functionality will be implemented in a future version.'),
        primaryButton: PushButton(
          buttonSize: ButtonSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  void _importData() {
    // TODO: Implement data import
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const MacosIcon(Icons.upload),
        title: const Text('Import Data'),
        message: const Text('Import functionality will be implemented in a future version.'),
        primaryButton: PushButton(
          buttonSize: ButtonSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  void _showKeyboardShortcuts() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  void _showAbout() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const MacosIcon(Icons.info),
        title: const Text('About TaskManager'),
        message: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('TaskManager v1.0.0'),
            SizedBox(height: 8),
            Text('A modern task management app for macOS'),
            SizedBox(height: 8),
            Text('Built with Flutter and following Apple Human Interface Guidelines'),
          ],
        ),
        primaryButton: PushButton(
          buttonSize: ButtonSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }
}

class PreferencesDialog extends StatefulWidget {
  const PreferencesDialog({super.key});

  @override
  State<PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(Icons.settings),
      title: const Text('Preferences'),
      message: const SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Text('Preferences panel will be implemented in a future version.'),
            SizedBox(height: 16),
            Text('Features to include:'),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Theme selection (Light/Dark/Auto)'),
                  Text('• Default view mode'),
                  Text('• Notification settings'),
                  Text('• Keyboard shortcuts'),
                  Text('• Data sync preferences'),
                  Text('• Export/Import options'),
                ],
              ),
            ),
          ],
        ),
      ),
      primaryButton: PushButton(
        buttonSize: ButtonSize.large,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    );
  }
}

class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(Icons.keyboard),
      title: const Text('Keyboard Shortcuts'),
      message: const SizedBox(
        width: 500,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShortcutSection(
                title: 'General',
                shortcuts: [
                  _Shortcut('⌘N', 'New Task'),
                  _Shortcut('⌘F', 'Search Tasks'),
                  _Shortcut('⌘⇧F', 'Clear Filters'),
                  _Shortcut('⌘R', 'Refresh'),
                  _Shortcut('⌘,', 'Preferences'),
                  _Shortcut('Esc', 'Close Dialog'),
                ],
              ),
              SizedBox(height: 16),
              _ShortcutSection(
                title: 'Filtering',
                shortcuts: [
                  _Shortcut('⌘1', 'Filter Low Priority'),
                  _Shortcut('⌘2', 'Filter Medium Priority'),
                  _Shortcut('⌘3', 'Filter High Priority'),
                  _Shortcut('⌘4', 'Filter Urgent Priority'),
                  _Shortcut('⌘⇧C', 'Toggle Completed Tasks'),
                ],
              ),
              SizedBox(height: 16),
              _ShortcutSection(
                title: 'Task Management',
                shortcuts: [
                  _Shortcut('Space', 'Toggle Task Completion'),
                  _Shortcut('Enter', 'Edit Selected Task'),
                  _Shortcut('Delete', 'Delete Selected Task'),
                  _Shortcut('↑/↓', 'Navigate Tasks'),
                ],
              ),
            ],
          ),
        ),
      ),
      primaryButton: PushButton(
        buttonSize: ButtonSize.large,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<_Shortcut> shortcuts;

  const _ShortcutSection({
    required this.title,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _Shortcut extends StatelessWidget {
  final String keys;
  final String description;

  const _Shortcut(this.keys, this.description);

  @override
  Widget build(BuildContext context) {
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
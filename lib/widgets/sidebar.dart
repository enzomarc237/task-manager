import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/project.dart';
import '../utils/theme.dart';

class TaskSidebar extends StatefulWidget {
  final Function(String?) onSelectionChanged;

  const TaskSidebar({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<TaskSidebar> createState() => _TaskSidebarState();
}

class _TaskSidebarState extends State<TaskSidebar> {
  String? _selectedItem = 'inbox';

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return MacosSidebar(
          minWidth: 200,
          maxWidth: 300,
          shownByDefault: true,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SidebarItems(
                currentIndex: _getSelectedIndex(),
                onChanged: _handleSelectionChanged,
                items: [
                  // Smart Lists
                  const SidebarItem(
                    leading: MacosIcon(Icons.inbox),
                    label: Text('Inbox'),
                  ),
                  SidebarItem(
                    leading: const MacosIcon(Icons.today),
                    label: const Text('Today'),
                    trailing: _buildBadge(taskProvider.todayTasks),
                  ),
                  SidebarItem(
                    leading: const MacosIcon(Icons.upcoming),
                    label: const Text('Upcoming'),
                  ),
                  SidebarItem(
                    leading: const MacosIcon(Icons.schedule),
                    label: const Text('Overdue'),
                    trailing: _buildBadge(taskProvider.overdueTasks, color: AppTheme.urgentColor),
                  ),
                  SidebarItem(
                    leading: const MacosIcon(Icons.check_circle),
                    label: const Text('Completed'),
                    trailing: _buildBadge(taskProvider.completedTasks, color: AppTheme.primaryGreen),
                  ),
                  
                  // Divider
                  const SidebarItem(
                    leading: SizedBox.shrink(),
                    label: Divider(),
                  ),
                  
                  // Projects Section
                  SidebarItem(
                    leading: const MacosIcon(Icons.folder),
                    label: Row(
                      children: [
                        const Expanded(child: Text('Projects')),
                        MacosIconButton(
                          icon: const MacosIcon(Icons.add, size: 16),
                          onPressed: _showNewProjectDialog,
                        ),
                      ],
                    ),
                  ),
                  
                  // Project Items
                  ...taskProvider.projects.map((project) => SidebarItem(
                    leading: MacosIcon(
                      _getProjectIcon(project.iconName),
                      color: project.color,
                    ),
                    label: Text(project.name),
                    trailing: _buildBadge(
                      taskProvider.getTasksForProject(project.id).length,
                    ),
                  )),
                  
                  // Divider
                  const SidebarItem(
                    leading: SizedBox.shrink(),
                    label: Divider(),
                  ),
                  
                  // Tags Section
                  const SidebarItem(
                    leading: MacosIcon(Icons.label),
                    label: Text('Tags'),
                  ),
                  
                  // Tag Items
                  ...taskProvider.getAllTags().take(10).map((tag) => SidebarItem(
                    leading: const MacosIcon(Icons.tag, size: 16),
                    label: Text('#$tag'),
                    trailing: _buildBadge(
                      taskProvider.getTasksByTag(tag).length,
                    ),
                  )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _getSelectedIndex() {
    switch (_selectedItem) {
      case 'inbox':
        return 0;
      case 'today':
        return 1;
      case 'upcoming':
        return 2;
      case 'overdue':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  void _handleSelectionChanged(int index) {
    String? newSelection;
    
    switch (index) {
      case 0:
        newSelection = 'inbox';
        break;
      case 1:
        newSelection = 'today';
        break;
      case 2:
        newSelection = 'upcoming';
        break;
      case 3:
        newSelection = 'overdue';
        break;
      case 4:
        newSelection = 'completed';
        break;
    }
    
    setState(() {
      _selectedItem = newSelection;
    });
    
    widget.onSelectionChanged(newSelection);
  }

  Widget _buildBadge(int count, {Color? color}) {
    if (count == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getProjectIcon(String? iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      case 'shopping':
        return Icons.shopping_cart;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.folder;
    }
  }

  void _showNewProjectDialog() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => const NewProjectDialog(),
    );
  }
}

class NewProjectDialog extends StatefulWidget {
  const NewProjectDialog({super.key});

  @override
  State<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _selectedColor = AppTheme.primaryBlue;
  String? _selectedIcon = 'folder';

  final List<Color> _availableColors = [
    AppTheme.primaryBlue,
    AppTheme.primaryGreen,
    AppTheme.primaryRed,
    AppTheme.primaryOrange,
    AppTheme.primaryYellow,
    AppTheme.primaryPurple,
    AppTheme.primaryPink,
    AppTheme.primaryTeal,
  ];

  final List<String> _availableIcons = [
    'folder',
    'work',
    'home',
    'school',
    'health',
    'shopping',
    'travel',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(Icons.create_new_folder),
      title: const Text('New Project'),
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MacosTextField(
            controller: _nameController,
            placeholder: 'Project name',
            autofocus: true,
          ),
          const SizedBox(height: 12),
          MacosTextField(
            controller: _descriptionController,
            placeholder: 'Description (optional)',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // Color Selection
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Color:'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Icon Selection
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Icon:'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _availableIcons.map((iconName) {
              final isSelected = iconName == _selectedIcon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = iconName;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: _selectedColor, width: 2)
                        : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    _getIconData(iconName),
                    color: isSelected ? _selectedColor : Colors.grey[600],
                    size: 20,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: _createProject,
        child: const Text('Create'),
      ),
      secondaryButton: PushButton(
        controlSize: ControlSize.large,
        secondary: true,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      case 'shopping':
        return Icons.shopping_cart;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.folder;
    }
  }

  void _createProject() {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    final project = Project(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      iconName: _selectedIcon,
    );

    Provider.of<TaskProvider>(context, listen: false).addProject(project);
    Navigator.of(context).pop();
  }
}
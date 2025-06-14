import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../utils/theme.dart';

class TaskDetailView extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final VoidCallback onClose;

  const TaskDetailView({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onClose,
  });

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  late Task _currentTask;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newSubtaskController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).scaffoldBackgroundColor,
        border: Border(
          left: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Description
                  _buildTitleSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Task Properties
                  _buildPropertiesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Subtasks
                  _buildSubtasksSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Tags
                  _buildTagsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Activity/Notes
                  _buildActivitySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Task completion toggle
          GestureDetector(
            onTap: _toggleTaskCompletion,
            child: AnimatedContainer(
              duration: AppTheme.shortAnimation,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _currentTask.isCompleted 
                    ? AppTheme.primaryGreen 
                    : Colors.transparent,
                border: Border.all(
                  color: _currentTask.isCompleted 
                      ? AppTheme.primaryGreen 
                      : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _currentTask.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Priority indicator
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: _getPriorityColor(_currentTask.priority),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Text(
              _currentTask.title,
              style: MacosTheme.of(context).typography.title2?.copyWith(
                decoration: _currentTask.isCompleted 
                    ? TextDecoration.lineThrough 
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Actions
          Row(
            children: [
              MacosIconButton(
                icon: MacosIcon(_isEditing ? Icons.check : Icons.edit),
                onPressed: _toggleEditing,
              ),
              MacosIconButton(
                icon: const MacosIcon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (_isEditing)
          MacosTextField(
            controller: _titleController,
            placeholder: 'Task title',
            style: MacosTheme.of(context).typography.title1,
          )
        else
          Text(
            _currentTask.title,
            style: MacosTheme.of(context).typography.title1?.copyWith(
              decoration: _currentTask.isCompleted 
                  ? TextDecoration.lineThrough 
                  : null,
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Description
        Text(
          'Description',
          style: MacosTheme.of(context).typography.headline,
        ),
        const SizedBox(height: 8),
        
        if (_isEditing)
          MacosTextField(
            controller: _descriptionController,
            placeholder: 'Add a description...',
            maxLines: 4,
          )
        else if (_currentTask.description.isNotEmpty)
          Text(
            _currentTask.description,
            style: MacosTheme.of(context).typography.body,
          )
        else
          Text(
            'No description',
            style: MacosTheme.of(context).typography.body?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Properties',
          style: MacosTheme.of(context).typography.headline,
        ),
        const SizedBox(height: 12),
        
        // Priority
        _buildPropertyRow(
          'Priority',
          _getPriorityText(_currentTask.priority),
          _getPriorityColor(_currentTask.priority),
          onTap: _isEditing ? _editPriority : null,
        ),
        
        // Due Date
        _buildPropertyRow(
          'Due Date',
          _currentTask.dueDate != null 
              ? DateFormat('MMM d, yyyy').format(_currentTask.dueDate!)
              : 'No due date',
          _currentTask.isOverdue ? AppTheme.urgentColor : null,
          onTap: _isEditing ? _editDueDate : null,
        ),
        
        // Created
        _buildPropertyRow(
          'Created',
          DateFormat('MMM d, yyyy').format(_currentTask.createdAt),
          null,
        ),
        
        // Estimated Effort
        if (_currentTask.estimatedEffort > 0)
          _buildPropertyRow(
            'Estimated',
            '${_currentTask.estimatedEffort} minutes',
            null,
            onTap: _isEditing ? _editEstimatedEffort : null,
          ),
        
        // Actual Effort
        if (_currentTask.actualEffort > 0)
          _buildPropertyRow(
            'Actual',
            '${_currentTask.actualEffort} minutes',
            null,
          ),
      ],
    );
  }

  Widget _buildPropertyRow(
    String label,
    String value,
    Color? valueColor, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: MacosTheme.of(context).typography.body?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: onTap != null
                    ? BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Text(
                  value,
                  style: MacosTheme.of(context).typography.body?.copyWith(
                    color: valueColor,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Subtasks',
              style: MacosTheme.of(context).typography.headline,
            ),
            const Spacer(),
            if (_currentTask.subtasks.isNotEmpty)
              Text(
                '${_currentTask.subtasks.where((s) => s.isCompleted).length}/${_currentTask.subtasks.length}',
                style: MacosTheme.of(context).typography.caption1?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Subtask list
        ...(_currentTask.subtasks.map((subtask) => _buildSubtaskItem(subtask))),
        
        // Add new subtask
        if (_isEditing) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MacosTextField(
                  controller: _newSubtaskController,
                  placeholder: 'Add a subtask...',
                  onSubmitted: _addSubtask,
                ),
              ),
              const SizedBox(width: 8),
              PushButton(
                buttonSize: ButtonSize.small,
                onPressed: _addSubtask,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubtaskItem(Subtask subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubtask(subtask),
            child: AnimatedContainer(
              duration: AppTheme.shortAnimation,
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: subtask.isCompleted 
                    ? AppTheme.primaryGreen 
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted 
                      ? AppTheme.primaryGreen 
                      : Colors.grey[400]!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.title,
              style: MacosTheme.of(context).typography.body?.copyWith(
                decoration: subtask.isCompleted 
                    ? TextDecoration.lineThrough 
                    : null,
                color: subtask.isCompleted 
                    ? Colors.grey[500] 
                    : null,
              ),
            ),
          ),
          if (_isEditing)
            MacosIconButton(
              icon: const MacosIcon(Icons.close, size: 14),
              onPressed: () => _removeSubtask(subtask),
            ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: MacosTheme.of(context).typography.headline,
        ),
        const SizedBox(height: 12),
        
        if (_currentTask.tags.isEmpty)
          Text(
            'No tags',
            style: MacosTheme.of(context).typography.body?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentTask.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Text(
                '#$tag',
                style: MacosTheme.of(context).typography.caption1?.copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: MacosTheme.of(context).typography.headline,
        ),
        const SizedBox(height: 12),
        
        // Creation activity
        _buildActivityItem(
          'Task created',
          _currentTask.createdAt,
          Icons.add_circle_outline,
        ),
        
        // Completion activity
        if (_currentTask.completedAt != null)
          _buildActivityItem(
            'Task completed',
            _currentTask.completedAt!,
            Icons.check_circle,
            color: AppTheme.primaryGreen,
          ),
        
        // Last modified
        if (_currentTask.lastModified != null && 
            _currentTask.lastModified != _currentTask.createdAt)
          _buildActivityItem(
            'Last modified',
            _currentTask.lastModified!,
            Icons.edit,
          ),
      ],
    );
  }

  Widget _buildActivityItem(
    String action,
    DateTime timestamp,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            action,
            style: MacosTheme.of(context).typography.body,
          ),
          const Spacer(),
          Text(
            DateFormat('MMM d, h:mm a').format(timestamp),
            style: MacosTheme.of(context).typography.caption1?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _toggleTaskCompletion() {
    setState(() {
      if (_currentTask.isCompleted) {
        _currentTask.markIncomplete();
      } else {
        _currentTask.markCompleted();
      }
    });
    widget.onTaskUpdated(_currentTask);
  }

  void _toggleEditing() {
    if (_isEditing) {
      // Save changes
      _currentTask = _currentTask.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      widget.onTaskUpdated(_currentTask);
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _toggleSubtask(Subtask subtask) {
    setState(() {
      subtask.toggle();
    });
    widget.onTaskUpdated(_currentTask);
  }

  void _addSubtask([String? value]) {
    final title = value ?? _newSubtaskController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        _currentTask.addSubtask(title);
      });
      _newSubtaskController.clear();
      widget.onTaskUpdated(_currentTask);
    }
  }

  void _removeSubtask(Subtask subtask) {
    setState(() {
      _currentTask.removeSubtask(subtask.id);
    });
    widget.onTaskUpdated(_currentTask);
  }

  void _editPriority() {
    // TODO: Show priority picker
  }

  void _editDueDate() {
    // TODO: Show date picker
  }

  void _editEstimatedEffort() {
    // TODO: Show effort picker
  }

  // Helper methods
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppTheme.urgentColor;
      case TaskPriority.high:
        return AppTheme.highColor;
      case TaskPriority.medium:
        return AppTheme.mediumColor;
      case TaskPriority.low:
        return AppTheme.lowColor;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
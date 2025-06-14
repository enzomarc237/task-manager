import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../utils/theme.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    this.isSelected = false,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MacosTheme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: widget.onTap,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(isDarkMode),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: widget.isSelected
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Completion checkbox
                      _buildCheckbox(),
                      
                      const SizedBox(width: 12),
                      
                      // Priority indicator
                      _buildPriorityIndicator(),
                      
                      const SizedBox(width: 8),
                      
                      // Task content
                      Expanded(
                        child: _buildTaskContent(),
                      ),
                      
                      // Due date and actions
                      _buildTrailingContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(bool isDarkMode) {
    if (widget.task.isCompleted) {
      return isDarkMode 
          ? Colors.grey[800]!.withOpacity(0.5)
          : Colors.grey[100]!;
    }
    
    if (widget.isSelected) {
      return AppTheme.primaryBlue.withOpacity(0.1);
    }
    
    if (_isHovered) {
      return isDarkMode 
          ? Colors.grey[800]!
          : Colors.grey[50]!;
    }
    
    return isDarkMode 
        ? const Color(0xFF2C2C2E)
        : Colors.white;
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: AppTheme.shortAnimation,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: widget.task.isCompleted 
              ? AppTheme.primaryGreen 
              : Colors.transparent,
          border: Border.all(
            color: widget.task.isCompleted 
                ? AppTheme.primaryGreen 
                : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: widget.task.isCompleted
            ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    final color = _getPriorityColor(widget.task.priority);
    final icon = _getPriorityIcon(widget.task.priority);
    
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.task.title,
          style: MacosTheme.of(context).typography.body?.copyWith(
            decoration: widget.task.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
            color: widget.task.isCompleted 
                ? Colors.grey[500] 
                : null,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Description (if present)
        if (widget.task.description.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            widget.task.description,
            style: MacosTheme.of(context).typography.caption1?.copyWith(
              color: Colors.grey[600],
              decoration: widget.task.isCompleted 
                  ? TextDecoration.lineThrough 
                  : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        
        // Tags and project
        if (widget.task.tags.isNotEmpty || widget.task.projectId != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              // Tags
              ...widget.task.tags.take(3).map((tag) => Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$tag',
                  style: MacosTheme.of(context).typography.caption2?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontSize: 10,
                  ),
                ),
              )),
              
              // Project indicator
              if (widget.task.projectId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '@project',
                    style: MacosTheme.of(context).typography.caption2?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
        
        // Subtasks progress
        if (widget.task.subtasks.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildSubtaskProgress(),
        ],
      ],
    );
  }

  Widget _buildSubtaskProgress() {
    final completedSubtasks = widget.task.subtasks.where((s) => s.isCompleted).length;
    final totalSubtasks = widget.task.subtasks.length;
    final progress = completedSubtasks / totalSubtasks;
    
    return Row(
      children: [
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completedSubtasks/$totalSubtasks',
          style: MacosTheme.of(context).typography.caption2?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Due date
        if (widget.task.dueDate != null) ...[
          _buildDueDate(),
          const SizedBox(height: 4),
        ],
        
        // Actions (visible on hover)
        if (_isHovered && !widget.task.isCompleted)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MacosIconButton(
                icon: const MacosIcon(Icons.edit, size: 16),
                onPressed: widget.onEdit,
              ),
              MacosIconButton(
                icon: const MacosIcon(Icons.delete, size: 16),
                onPressed: widget.onDelete,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDueDate() {
    final dueDate = widget.task.dueDate!;
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(now) && !widget.task.isCompleted;
    final isToday = dueDate.year == now.year && 
                   dueDate.month == now.month && 
                   dueDate.day == now.day;
    final isTomorrow = dueDate.difference(now).inDays == 1;
    
    String dateText;
    Color dateColor;
    
    if (isOverdue) {
      dateText = 'Overdue';
      dateColor = AppTheme.urgentColor;
    } else if (isToday) {
      dateText = 'Today';
      dateColor = AppTheme.primaryOrange;
    } else if (isTomorrow) {
      dateText = 'Tomorrow';
      dateColor = AppTheme.primaryBlue;
    } else {
      dateText = DateFormat('MMM d').format(dueDate);
      dateColor = Colors.grey[600]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOverdue 
            ? AppTheme.urgentColor.withOpacity(0.1)
            : isToday
                ? AppTheme.primaryOrange.withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isOverdue || isToday
            ? Border.all(
                color: isOverdue ? AppTheme.urgentColor : AppTheme.primaryOrange,
                width: 1,
              )
            : null,
      ),
      child: Text(
        dateText,
        style: MacosTheme.of(context).typography.caption2?.copyWith(
          color: dateColor,
          fontSize: 10,
          fontWeight: isOverdue || isToday ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

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

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Icons.priority_high;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.arrow_downward;
    }
  }
}
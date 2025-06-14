import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/theme.dart';

class QuickEntryBar extends StatefulWidget {
  const QuickEntryBar({super.key});

  @override
  State<QuickEntryBar> createState() => _QuickEntryBarState();
}

class _QuickEntryBarState extends State<QuickEntryBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;
  List<String> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          Row(
            children: [
              const MacosIcon(
                Icons.add_circle_outline,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MacosTextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  placeholder: 'Quick add: "Buy groceries today #shopping @home urgent"',
                  onChanged: _handleTextChanged,
                  onSubmitted: _handleSubmitted,
                  onTap: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              PushButton(
                onPressed: _controller.text.trim().isNotEmpty ? _createTask : null,
                controlSize: ControlSize.large,
                child: const Text('Add'),
              ),
            ],
          ),
          
          // Suggestions and help
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            _buildSuggestionsAndHelp(),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsAndHelp() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggestions
          if (_suggestions.isNotEmpty) ...[
            const Text(
              'Suggestions:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _suggestions.map((suggestion) {
                return GestureDetector(
                  onTap: () => _applySuggestion(suggestion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Help text
          const Text(
            'Natural Language Examples:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpExample(
                'Time:',
                'today, tomorrow, next week, Monday',
              ),
              _HelpExample(
                'Priority:',
                'urgent, high priority, low priority',
              ),
              _HelpExample(
                'Projects:',
                '@work, @home, @personal',
              ),
              _HelpExample(
                'Tags:',
                '#important, #quick, #shopping',
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: MacosIconButton(
              icon: const MacosIcon(Icons.close, size: 16),
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
                _focusNode.unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTextChanged(String text) {
    setState(() {
      _suggestions = _generateSuggestions(text);
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      _createTask();
    }
  }

  void _createTask() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = taskProvider.parseNaturalLanguageTask(_controller.text.trim());
    
    taskProvider.addTask(task);
    
    _controller.clear();
    setState(() {
      _isExpanded = false;
      _suggestions.clear();
    });
    
    _focusNode.unfocus();
    
    // Show success feedback
    _showTaskCreatedFeedback(task);
  }

  void _applySuggestion(String suggestion) {
    final currentText = _controller.text;
    final newText = '$currentText $suggestion';
    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    
    setState(() {
      _suggestions = _generateSuggestions(newText);
    });
  }

  List<String> _generateSuggestions(String text) {
    final suggestions = <String>[];
    final lowerText = text.toLowerCase();
    
    // Time suggestions
    if (!lowerText.contains('today') && 
        !lowerText.contains('tomorrow') && 
        !lowerText.contains('next week')) {
      suggestions.addAll(['today', 'tomorrow', 'next week']);
    }
    
    // Priority suggestions
    if (!lowerText.contains('urgent') && 
        !lowerText.contains('high') && 
        !lowerText.contains('low')) {
      suggestions.addAll(['urgent', 'high priority']);
    }
    
    // Common tags
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final existingTags = taskProvider.getAllTags();
    
    for (final tag in existingTags.take(5)) {
      if (!lowerText.contains('#$tag')) {
        suggestions.add('#$tag');
      }
    }
    
    // Common projects
    final projects = taskProvider.projects;
    for (final project in projects.take(3)) {
      if (!lowerText.contains('@${project.name.toLowerCase()}')) {
        suggestions.add('@${project.name}');
      }
    }
    
    return suggestions.take(8).toList();
  }

  void _showTaskCreatedFeedback(Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Task "${task.title}" created successfully',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _HelpExample extends StatelessWidget {
  final String category;
  final String examples;

  const _HelpExample(this.category, this.examples);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              examples,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
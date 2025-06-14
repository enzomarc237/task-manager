import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/services.dart';

import 'providers/task_provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'views/main_window.dart';
import 'utils/theme.dart';
import 'utils/keyboard_shortcuts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.initialize();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(TaskManagerApp(
    storageService: storageService,
    notificationService: notificationService,
  ));
}

class TaskManagerApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;

  const TaskManagerApp({
    super.key,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TaskProvider(storageService, notificationService),
        ),
      ],
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return MacosApp(
            title: 'TaskManager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: KeyboardShortcuts(
              child: const MainWindow(),
            ),
          );
        },
      ),
    );
  }
}

class KeyboardShortcuts extends StatefulWidget {
  final Widget child;

  const KeyboardShortcuts({
    super.key,
    required this.child,
  });

  @override
  State<KeyboardShortcuts> createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        return KeyboardShortcutHandler.handleKeyEvent(context, event);
      },
      child: widget.child,
    );
  }
}
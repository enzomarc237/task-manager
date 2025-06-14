# TaskManager for macOS

A modern, intuitive task management application built with Flutter, designed specifically for macOS following Apple's Human Interface Guidelines.

![TaskManager Screenshot](assets/images/screenshot-light.png)

## Features

### Core Functionality
- ✅ **Smart Task Creation** - Natural language processing for quick task entry
- ✅ **Intelligent Categorization** - Projects, contexts, and tags for organization
- ✅ **Priority Management** - Four-level priority system with visual indicators
- ✅ **Due Date Tracking** - Time-based notifications and overdue detection
- ✅ **Subtask Support** - Break down complex tasks into manageable steps
- ✅ **Progress Tracking** - Visual indicators and completion statistics
- ✅ **Drag & Drop** - Intuitive reordering and prioritization
- ✅ **Search & Filter** - Powerful filtering across all task attributes

### macOS Integration
- 🎨 **Native Design** - Follows macOS Sonoma/Ventura design principles
- 🌓 **Light & Dark Mode** - Automatic theme switching
- ⌨️ **Keyboard Shortcuts** - Full keyboard navigation support
- 🔍 **Spotlight Integration** - System-wide task search
- 🔔 **Native Notifications** - macOS notification center integration
- ♿ **Accessibility** - VoiceOver and keyboard navigation support

### User Experience
- 🚀 **Quick Entry** - Create tasks in 3 clicks or fewer
- 📱 **Responsive Layout** - Adapts to different window sizes
- 🎯 **Focus Mode** - Highlight immediate priorities
- 🔄 **Recurring Tasks** - Flexible scheduling options
- 📊 **Multiple Views** - List, Kanban, and Calendar views
- 💾 **Auto-save** - Never lose your work

## Screenshots

### Light Mode
![Light Mode](assets/images/screenshot-light.png)

### Dark Mode
![Dark Mode](assets/images/screenshot-dark.png)

### Task Detail View
![Task Detail](assets/images/screenshot-detail.png)

## Installation

### Prerequisites
- macOS Ventura (13.0) or later
- Flutter 3.10.0 or later
- Dart 3.0.0 or later

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/taskmanager-macos.git
   cd taskmanager-macos
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run -d macos
   ```

### Building for Release

1. **Build the macOS app**
   ```bash
   flutter build macos --release
   ```

2. **Create a distributable package**
   ```bash
   cd build/macos/Build/Products/Release/
   zip -r TaskManager.zip TaskManager.app
   ```

## Usage

### Quick Start

1. **Create your first task**
   - Use the quick entry bar: "Buy groceries today #shopping urgent"
   - Or click the + button in the toolbar

2. **Organize with projects**
   - Create projects in the sidebar
   - Assign tasks to projects using @project syntax

3. **Set priorities and due dates**
   - Use natural language: "urgent", "high priority", "today", "tomorrow"
   - Or set them manually in the task detail view

4. **Track progress**
   - Check off completed tasks
   - Add subtasks for complex projects
   - Monitor progress with visual indicators

### Natural Language Examples

The quick entry bar supports natural language input:

- **Time**: "today", "tomorrow", "next week", "Monday"
- **Priority**: "urgent", "high priority", "low priority"
- **Projects**: "@work", "@home", "@personal"
- **Tags**: "#important", "#quick", "#shopping"

**Examples:**
- "Call dentist tomorrow urgent"
- "Review presentation @work high priority"
- "Buy milk today #shopping"
- "Plan vacation next week @personal #travel"

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘N | New Task |
| ⌘F | Search Tasks |
| ⌘⇧F | Clear Filters |
| ⌘R | Refresh |
| ⌘, | Preferences |
| ⌘1-4 | Filter by Priority |
| ⌘⇧C | Toggle Completed Tasks |
| Space | Toggle Task Completion |
| Enter | Edit Selected Task |
| Delete | Delete Selected Task |
| ↑/↓ | Navigate Tasks |
| Esc | Close Dialog |

## Architecture

### Project Structure
```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── task.dart            # Task model with Hive annotations
│   ├── project.dart         # Project model
│   └── app_settings.dart    # Application settings
├── providers/               # State management
│   └── task_provider.dart   # Main task provider
├── services/                # Business logic
│   ├── storage_service.dart # Local data persistence
│   └── notification_service.dart # Notification handling
├── views/                   # Main screens
│   └── main_window.dart     # Primary application window
├── widgets/                 # Reusable UI components
│   ├── sidebar.dart         # Navigation sidebar
│   ├── toolbar.dart         # Top toolbar
│   ├── quick_entry.dart     # Quick task entry
│   ├── task_list_view.dart  # Task list display
│   ├── task_item.dart       # Individual task item
│   └── task_detail_view.dart # Task detail panel
└── utils/                   # Utilities and helpers
    ├── theme.dart           # App theming
    └── keyboard_shortcuts.dart # Keyboard handling
```

### State Management
- **Provider Pattern** - Simple, efficient state management
- **Local Storage** - Hive database for offline capability
- **Auto-persistence** - Automatic saving of changes

### Design Patterns
- **Repository Pattern** - Data access abstraction
- **Observer Pattern** - UI updates via Provider
- **Factory Pattern** - Model creation and parsing
- **Singleton Pattern** - Service instances

## Development

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation for public APIs
- Maintain consistent formatting with `dart format`

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Quality
- Maintain test coverage above 80%
- Follow established patterns and conventions
- Update documentation for new features
- Ensure accessibility compliance

## Configuration

### App Settings
The application stores settings in `~/Library/Application Support/TaskManager/`:
- `tasks.hive` - Task data
- `projects.hive` - Project data
- `settings.hive` - Application preferences

### Customization
- **Themes** - Light/Dark mode with system preference detection
- **Shortcuts** - Customizable keyboard shortcuts
- **Notifications** - Configurable reminder timing
- **Views** - Default view mode selection

## Troubleshooting

### Common Issues

**App won't start**
- Ensure macOS version compatibility (13.0+)
- Check Flutter installation: `flutter doctor`
- Verify dependencies: `flutter pub get`

**Data not saving**
- Check file permissions in Application Support folder
- Clear app data: Delete `~/Library/Application Support/TaskManager/`
- Restart the application

**Notifications not working**
- Grant notification permissions in System Preferences
- Check notification settings in the app
- Restart the notification service

**Performance issues**
- Limit number of visible tasks (use filters)
- Archive completed tasks regularly
- Check available disk space

### Debug Mode
Run with debug flags for troubleshooting:
```bash
flutter run -d macos --debug --verbose
```

## Roadmap

### Version 1.1
- [ ] Calendar view implementation
- [ ] Kanban board view
- [ ] Advanced recurring task patterns
- [ ] Time tracking functionality
- [ ] Export to various formats

### Version 1.2
- [ ] iCloud synchronization
- [ ] iOS companion app
- [ ] Team collaboration features
- [ ] Advanced reporting and analytics
- [ ] Plugin system for extensions

### Version 2.0
- [ ] AI-powered task suggestions
- [ ] Voice input support
- [ ] Advanced automation rules
- [ ] Integration with external services
- [ ] Multi-language support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Apple** - For the excellent Human Interface Guidelines
- **Flutter Team** - For the amazing cross-platform framework
- **macOS UI Package** - For native macOS components
- **Community Contributors** - For feedback and contributions

## Support

- **Documentation** - [Wiki](https://github.com/yourusername/taskmanager-macos/wiki)
- **Issues** - [GitHub Issues](https://github.com/yourusername/taskmanager-macos/issues)
- **Discussions** - [GitHub Discussions](https://github.com/yourusername/taskmanager-macos/discussions)
- **Email** - support@taskmanager.app

---

**Made with ❤️ for macOS productivity enthusiasts**
# Simple Todo - Flutter Task Management App

A modern, feature-rich todo application built with Flutter that helps you organize and manage your tasks efficiently with beautiful animations and seamless data management.

<br>

## 📋 Features

### Core Functionality
- **Task Management**: Create, edit, delete, and organize your tasks
- **Status Tracking**: Track tasks with three states - Ready, Pending, and Completed
- **Smart Time Display**: Relative time formatting (e.g., "2 hours ago", "Yesterday")
- **Persistent Storage**: All data stored locally using Isar database

### Modern UI/UX
- **Glass-morphism Design**: Beautiful card-based interface with backdrop blur effects
- **Smooth Animations**: Entry and exit animations for tasks
- **Status Indicators**: Color-coded status badges with icons
- **Interactive Elements**: Tap-to-change status with popup menus
- **Responsive Design**: Optimized for various screen sizes

### Data Import/Export
- **CSV Export**: Export all tasks to CSV format for backup
- **Universal Import**: Import tasks from both CSV and JSON files
- **File Sharing**: Built-in sharing capabilities for exported files
- **Smart Detection**: Automatically detects file format during import
- **Real-time Updates**: Reactive UI that updates instantly
- **Error Handling**: Comprehensive error handling with user feedback

<br>

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Database**: Isar (NoSQL)
- **File Operations**: file_picker, share_plus
- **UI Components**: Custom widgets with Material Design
- **Animations**: Flutter's built-in animation system

<br>

## 🏗️ Architecture

```
lib/
├── core/
│   ├── config/           # App configuration and constants
│   ├── data/
│   │   └── local/        # Database models and services
│   ├── design/           # Colors, themes, and design tokens
│   ├── extensions/       # Dart extensions for utilities
│   └── common/
│       └── widgets/      # Reusable UI components
├── features/
│   └── home/
│       ├── controllers/  # Business logic and state management
│       ├── views/        # UI screens
│       └── widgets/      # Feature-specific widgets
└── services/             # External service integrations
```

<br>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

<br>

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/shahriartoky0/simple-todo.git
cd simple-todo
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Generate code (for Isar database)**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**4. Run the application**
```bash
flutter run
```

<br>

## 📦 Dependencies

### Production Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  isar: ^3.1.8                    # Local database
  isar_flutter_libs: ^3.1.8      # Isar Flutter bindings
  path_provider: ^2.1.4          # File system paths
  file_picker: ^8.1.2            # File selection
  share_plus: ^10.0.2            # File sharing
  get: ^4.6.6                    # State management
  intl: ^0.18.1                  # Internationalization
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  isar_generator: ^3.1.8         # Code generation
  build_runner: ^2.4.13          # Build system
  analyzer: ^6.4.1               # Static analysis
```

<br>

## 📱 Usage

### Creating Tasks
1. Tap the floating action button (+)
2. Enter task title and description
3. Task is automatically set to "Pending" status
4. Tap "Add Task" to save

<br>

### Managing Tasks
- **Edit**: Tap the menu icon → Edit
- **Delete**: Tap the menu icon → Delete
- **Change Status**: Tap the status badge to cycle through states
- **View Details**: All information displayed on the task card

<br>

### Import/Export
- **Export**: Tap "Export" in the app bar to save tasks as CSV
- **Import**: Tap "Import" in the add task modal to load from CSV/JSON files

<br>

## 📄 Supported File Formats

### CSV Format
```csv
ID,Title,Description,Status,CreatedAt
1,"Buy groceries","Need milk and bread","pending","1693574400000"
```

### JSON Format
```json
{
  "tasks": [
    {
      "title": "Buy groceries",
      "description": "Need milk and bread",
      "status": "pending",
      "createdAt": 1693574400000
    }
  ]
}
```

<br>

## 🗄️ Database Schema

### Task Model
```dart
class Task {
  Id id;                    // Auto-generated unique identifier
  String title;             // Task title (required)
  String description;       // Task description (required)
  DateTime createdAt;       // Creation timestamp
  TaskStatus status;        // ready | pending | completed
}
```

<br>

## 🎨 Customization

### Colors
Update colors in `lib/core/design/app_colors.dart`:
```dart
class AppColors {
  static const Color primaryColor = Color(0xFF002454);
  static const Color green = Color(0xFF24A584);
  static const Color orange = Color(0xFFFF8133);
  // ... more colors
}
```

### Animations
Modify animation durations in the widget constructors:
```dart
AnimatedTaskTile(
  animationDuration: Duration(milliseconds: 500),
  animationCurve: Curves.easeOutBack,
  child: TaskTile(...),
)
```

<br>

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

<br>

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write descriptive commit messages
- Add comments for complex logic
- Test on both Android and iOS
- Update README for new features

<br>

## ⚡ Performance Considerations

- **Database**: Isar provides excellent performance for local storage
- **Animations**: Optimized for 60fps with efficient rebuilds
- **Memory**: Reactive state management prevents memory leaks
- **File Operations**: Asynchronous operations prevent UI blocking

<br>

## 🔧 Troubleshooting

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Database Issues
- Delete app data to reset database
- Check Isar version compatibility
- Verify model generation completed successfully

<br>

## 🚧 Future Enhancements

- [ ] Task categories and labels
- [ ] Due dates and reminders
- [ ] Task priorities
- [ ] Dark mode support
- [ ] Cloud synchronization
- [ ] Task templates
- [ ] Advanced filtering
- [ ] Statistics and analytics



## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Isar team for the efficient local database
- GetX community for state management solutions
- Material Design for UI/UX guidelines

<br>

## 📞 Contact

For questions, suggestions, or support:
- **Email**: tokyshahriar555@gmail.com
 
<br>

---

**Made with Flutter 💙**
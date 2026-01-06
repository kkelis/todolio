# ToDoLio

A beautiful, modern Flutter app for managing reminders, to-do lists, shopping lists, guarantee tracking, and notes. Built with a local-first architecture - all data is stored on your device with no cloud dependencies.

## ✨ Features

- **Reminders** - Schedule reminders for birthdays, appointments, todos, and other events with notifications
  - Repeat functionality (daily, weekly, monthly, yearly)
  - Snooze options (5min, 15min, 30min)
  - Grouped by date (Today, Next 7 days, Overdue, Completed)
  - Notifications persist after device reboot
- **To-Do Lists** - Organize tasks with priorities and due dates
  - Same unified model as reminders
  - Grouped by priority (High, Medium, Low)
  - Can have due dates and appear in reminders view
- **Shopping Lists** - Create and manage shopping lists with CSV export/import
  - Unit selection (piece, liter, kg, etc.)
  - Quantity and unit tracking
  - CSV export/import for sharing
- **Guarantee Tracking** - Track warranties with photos, expiry dates, and notes
  - Customizable reminder notifications (1, 2, or 3 months before expiry)
  - Local photo storage for warranty and receipt
- **Notes** - Rich notes with tags, colors, and pinning support
- **Settings** - Enable/disable app sections to customize your experience

## 🎨 Design

- Modern gradient background (#5056cb to #8c92f9)
- White modal dialogs with primary color accents
- Roboto font family
- White cards with shadows on main screens
- Collapsible UI elements for better space usage
- Completed items with primary color background and white text
- Smooth animations and transitions
- Swipe navigation between sections

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd todolio
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

**No additional setup required!** The app works 100% offline with local storage.

## 📱 Platform Support

- ✅ Android
- ✅ iOS

## 🏗️ Architecture

- **Local-First** - All data stored locally using Hive
- **No Cloud** - No Firebase, no authentication, no external dependencies
- **State Management** - Riverpod 3.x
- **Real-time Updates** - Stream-based reactive UI
- **Reliable Notifications** - Uses native AlarmManager.setAlarmClock() for persistent alarms
- **Boot Persistence** - Notifications survive device reboots automatically

## 📦 Key Dependencies

- `flutter_riverpod` - State management
- `hive` / `hive_flutter` - Local database
- `flutter_local_notifications` - Local notifications
- `image_picker` - Camera integration
- `file_picker` - CSV file import
- `share_plus` - CSV export/sharing
- `intl` - Date formatting
- `timezone` - Timezone support for notifications

## 🔒 Privacy

- **100% Local** - All data stored on your device only
- **No Cloud Sync** - No data sent to external servers
- **Complete Privacy** - Your data stays on your device

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 Karlo Keliš

## 📝 Documentation

See `IMPLEMENTATION_SUMMARY.md` for detailed feature documentation.

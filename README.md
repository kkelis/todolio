# TodoLio

A beautiful, modern Flutter app for managing reminders, to-do lists, shopping lists, guarantee tracking, and notes. Built with a local-first architecture - all data is stored on your device with no cloud dependencies.

## ✨ Features

- **Reminders** - Schedule reminders for birthdays, appointments, and other events with notifications
- **To-Do Lists** - Organize tasks with priorities and due dates
- **Shopping Lists** - Create and manage shopping lists with CSV export/import
- **Guarantee Tracking** - Track warranties with photos, expiry dates, and storage locations
- **Notes** - Rich notes with tags, colors, and pinning support

## 🎨 Design

- Modern gradient background (#5056cb to #8c92f9)
- White modal dialogs with primary color accents
- Roboto font family
- Glassmorphic cards on main screens
- Smooth animations and transitions

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

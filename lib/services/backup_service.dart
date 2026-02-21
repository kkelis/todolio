import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'local_storage_service.dart';

enum BackupImportMode {
  replace, // Replace all existing data
  merge, // Merge with existing data
}

class BackupService {
  static const String backupVersion = '1.0';

  /// Export all app data to a ZIP file and share it
  /// Returns true if backup was successfully shared, false if cancelled
  Future<bool> exportBackup() async {
    try {
      // Create temporary directory for backup
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;
      final backupDirPath = '${tempDir.path}/todolio_backup_$timestamp';
      final backupDir = Directory(backupDirPath);
      await backupDir.create(recursive: true);

      // Collect all data from Hive boxes
      final backupData = await _collectAllData();

      // Write JSON file
      final jsonFile = File('${backupDir.path}/backup.json');
      await jsonFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
      );

      // Copy images directory if it exists
      final imagesDir = await _getImagesDirectory();
      Directory? backupImagesDir;
      if (await imagesDir.exists()) {
        backupImagesDir = Directory('${backupDir.path}/images');
        await backupImagesDir.create();
        await _copyDirectory(imagesDir, backupImagesDir);
      }

      // Create ZIP file with human-readable timestamp
      final formattedDate = _formatDateTimeForFilename(now);
      final zipFilePath = '${tempDir.path}/todolio_backup_$formattedDate.zip';
      
      // Create ZIP archive manually to control structure
      final archive = Archive();
      
      // Add backup.json to root of ZIP
      final jsonBytes = await jsonFile.readAsBytes();
      archive.addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes));
      
      // Add images to ZIP if they exist
      if (backupImagesDir != null && await backupImagesDir.exists()) {
        await for (final entity in backupImagesDir.list(recursive: true)) {
          if (entity is File) {
            final relativePath = entity.path.substring(backupDir.path.length + 1);
            final fileBytes = await entity.readAsBytes();
            archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));
          }
        }
      }
      
      // Encode and write ZIP file
      final zipData = ZipEncoder().encode(archive);
      await File(zipFilePath).writeAsBytes(zipData);

      // Clean up temporary backup directory
      await backupDir.delete(recursive: true);

      // Share the ZIP file
      // TODO: Update when share_plus provides replacement for deprecated shareXFiles
      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(zipFilePath)],
        text: 'Todolio Backup - ${_formatDateTimeReadable(now)}',
        subject: 'Todolio Backup',
      );

      // Clean up ZIP file after sharing
      await File(zipFilePath).delete();

      return result.status == ShareResultStatus.success;
    } catch (e) {
      rethrow;
    }
  }

  /// Import backup from a ZIP file
  /// Returns true if import was successful
  Future<bool> importBackup(BackupImportMode mode) async {
    try {
      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return false; // User cancelled
      }

      final file = result.files.first;

      // Create temporary directory for extraction
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extractDirPath = '${tempDir.path}/todolio_extract_$timestamp';
      final extractDir = Directory(extractDirPath);
      await extractDir.create(recursive: true);

      // Read ZIP file
      List<int> zipBytes;
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        zipBytes = file.bytes!;
      } else if (file.path != null && file.path!.isNotEmpty) {
        final fileHandle = File(file.path!);
        zipBytes = await fileHandle.readAsBytes();
      } else {
        throw Exception('Unable to read backup file');
      }

      // Extract ZIP
      final archive = ZipDecoder().decodeBytes(zipBytes);
      for (final archiveFile in archive) {
        final filename = archiveFile.name;
        if (archiveFile.isFile) {
          final outFile = File('${extractDir.path}/$filename');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(archiveFile.content as List<int>);
        }
      }

      // Read backup.json
      final jsonFile = File('${extractDir.path}/backup.json');
      if (!await jsonFile.exists()) {
        throw Exception('Invalid backup file: backup.json not found');
      }

      final jsonContent = await jsonFile.readAsString();
      final backupData = json.decode(jsonContent) as Map<String, dynamic>;

      // Validate backup version
      final version = backupData['version'] as String?;
      if (version == null) {
        throw Exception('Invalid backup file: version not found');
      }

      // Import data based on mode
      await _importData(backupData, mode);

      // Import images if they exist
      final backupImagesDir = Directory('${extractDir.path}/images');
      if (await backupImagesDir.exists()) {
        final appImagesDir = await _getImagesDirectory();
        await appImagesDir.create(recursive: true);
        
        if (mode == BackupImportMode.replace) {
          // Delete existing images
          if (await appImagesDir.exists()) {
            await appImagesDir.delete(recursive: true);
            await appImagesDir.create(recursive: true);
          }
        }
        
        await _copyDirectory(backupImagesDir, appImagesDir);
      }

      // Clean up extraction directory
      await extractDir.delete(recursive: true);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Collect all data from Hive boxes
  Future<Map<String, dynamic>> _collectAllData() async {
    final remindersBox = await Hive.openBox(LocalStorageService.remindersBox);
    final shoppingListsBox = await Hive.openBox(LocalStorageService.shoppingListsBox);
    final guaranteesBox = await Hive.openBox(LocalStorageService.guaranteesBox);
    final notesBox = await Hive.openBox(LocalStorageService.notesBox);
    final loyaltyCardsBox = await Hive.openBox(LocalStorageService.loyaltyCardsBox);
    final settingsBox = await Hive.openBox(LocalStorageService.settingsBox);

    return {
      'version': backupVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'reminders': remindersBox.get('reminders') ?? [],
      'shoppingLists': shoppingListsBox.get('shoppingLists') ?? [],
      'guarantees': guaranteesBox.get('guarantees') ?? [],
      'notes': notesBox.get('notes') ?? [],
      'loyaltyCards': loyaltyCardsBox.get('loyaltyCards') ?? [],
      'settings': settingsBox.get('settings') ?? {},
    };
  }

  /// Import data into Hive boxes
  Future<void> _importData(Map<String, dynamic> backupData, BackupImportMode mode) async {
    final remindersBox = await Hive.openBox(LocalStorageService.remindersBox);
    final shoppingListsBox = await Hive.openBox(LocalStorageService.shoppingListsBox);
    final guaranteesBox = await Hive.openBox(LocalStorageService.guaranteesBox);
    final notesBox = await Hive.openBox(LocalStorageService.notesBox);
    final loyaltyCardsBox = await Hive.openBox(LocalStorageService.loyaltyCardsBox);
    final settingsBox = await Hive.openBox(LocalStorageService.settingsBox);

    if (mode == BackupImportMode.replace) {
      // Replace: Simply overwrite all data
      await remindersBox.put('reminders', backupData['reminders'] ?? []);
      await shoppingListsBox.put('shoppingLists', backupData['shoppingLists'] ?? []);
      await guaranteesBox.put('guarantees', backupData['guarantees'] ?? []);
      await notesBox.put('notes', backupData['notes'] ?? []);
      await loyaltyCardsBox.put('loyaltyCards', backupData['loyaltyCards'] ?? []);
      await settingsBox.put('settings', backupData['settings'] ?? {});
    } else {
      // Merge: Combine backup data with existing data
      await _mergeData(remindersBox, 'reminders', backupData['reminders']);
      await _mergeData(shoppingListsBox, 'shoppingLists', backupData['shoppingLists']);
      await _mergeData(guaranteesBox, 'guarantees', backupData['guarantees']);
      await _mergeData(notesBox, 'notes', backupData['notes']);
      await _mergeData(loyaltyCardsBox, 'loyaltyCards', backupData['loyaltyCards']);
      
      // For settings, prefer backup settings but keep current if not in backup
      final currentSettings = settingsBox.get('settings') as Map<String, dynamic>? ?? {};
      final backupSettings = backupData['settings'] as Map<String, dynamic>? ?? {};
      final mergedSettings = {...currentSettings, ...backupSettings};
      await settingsBox.put('settings', mergedSettings);
    }
  }

  /// Merge backup data with existing data (avoiding duplicates by ID)
  Future<void> _mergeData(Box box, String key, dynamic backupData) async {
    if (backupData == null || backupData is! List) return;

    final existingData = box.get(key) as List<dynamic>? ?? [];
    final existingIds = <String>{};
    
    // Collect existing IDs
    for (final item in existingData) {
      if (item is Map) {
        final id = item['id'] as String?;
        if (id != null) existingIds.add(id);
      }
    }

    // Add backup items that don't exist
    final mergedData = [...existingData];
    for (final item in backupData) {
      if (item is Map) {
        final id = item['id'] as String?;
        if (id != null && !existingIds.contains(id)) {
          mergedData.add(item);
        }
      }
    }

    await box.put(key, mergedData);
  }

  /// Get images directory
  Future<Directory> _getImagesDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory('${directory.path}/images');
  }

  /// Copy directory recursively
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    
    await for (final entity in source.list(recursive: false)) {
      if (entity is File) {
        final newPath = '${destination.path}/${entity.uri.pathSegments.last}';
        await entity.copy(newPath);
      } else if (entity is Directory) {
        final newDir = Directory('${destination.path}/${entity.uri.pathSegments.last}');
        await _copyDirectory(entity, newDir);
      }
    }
  }

  /// Format date for filename (YYYY-MM-DD_HH-MM-SS)
  String _formatDateTimeForFilename(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_'
           '${date.hour.toString().padLeft(2, '0')}-${date.minute.toString().padLeft(2, '0')}-${date.second.toString().padLeft(2, '0')}';
  }

  /// Format date and time for readable display
  String _formatDateTimeReadable(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

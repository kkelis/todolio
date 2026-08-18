import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

class CsvService {
  /// Export shopping list to CSV format
  /// Returns true if user actually shared, false if cancelled
  Future<bool> exportShoppingList(ShoppingList list) async {
    final csvContent = _generateCsv(list);
    final fileName = '${list.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
    
    // Save to temporary file and share
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvContent);
    
    // TODO: Update when share_plus provides replacement for deprecated shareXFiles
    // ignore: deprecated_member_use
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Shopping List: ${list.name}',
      subject: list.name,
    );
    
    // Check if user actually shared or cancelled
    return result.status == ShareResultStatus.success;
  }

  /// Generate CSV content from shopping list
  String _generateCsv(ShoppingList list) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Item Name,Quantity,Unit,Completed');
    
    // Items
    for (final item in list.items) {
      final name = _escapeCsvField(item.name);
      final quantity = item.quantity.toString();
      final unit = item.unit.displayName;
      final completed = item.isCompleted ? 'Yes' : 'No';
      buffer.writeln('$name,$quantity,$unit,$completed');
    }
    
    return buffer.toString();
  }

  /// Escape CSV field (handle commas, quotes, newlines)
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Import shopping list from CSV file
  Future<ShoppingList?> importShoppingList() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'], // Allow txt as well in case CSV extension is missing
      );

      if (file == null) {
        return null;
      }

      final fileBytes = await file.readAsBytes();
      String csvContent;
      try {
        csvContent = utf8.decode(fileBytes);
      } catch (_) {
        csvContent = const Latin1Codec().decode(fileBytes);
      }

      if (csvContent.trim().isEmpty) {
        throw Exception('CSV file is empty');
      }

      return _parseCsv(csvContent, file.name);
    } catch (e) {
      throw Exception('Failed to import CSV: ${e.toString()}');
    }
  }

  /// Parse CSV content into ShoppingList
  ShoppingList _parseCsv(String csvContent, String fileName) {
    final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) {
      throw Exception('CSV file is empty');
    }

    // Skip header if present
    int startIndex = 0;
    bool hasUnitColumn = false;
    
    if (lines[0].toLowerCase().contains('item') || 
        lines[0].toLowerCase().contains('name') ||
        lines[0].toLowerCase().contains('quantity')) {
      startIndex = 1;
      // Detect if CSV has unit column (new format) or not (old format)
      hasUnitColumn = lines[0].toLowerCase().contains('unit');
    }

    final items = <ShoppingItem>[];
    
    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final fields = _parseCsvLine(line);
        
        if (fields.length >= 2) {
          final name = fields[0].trim();
          if (name.isEmpty) continue;

          final quantity = double.tryParse(fields[1].trim()) ?? 1.0;
          
          // Parse unit (if present) or default to piece
          ShoppingUnit unit = ShoppingUnit.piece;
          int completedIndex = 2;
          
          if (hasUnitColumn && fields.length >= 3) {
            final unitStr = fields[2].trim().toLowerCase();
            unit = ShoppingUnit.values.firstWhere(
              (u) => u.displayName.toLowerCase() == unitStr,
              orElse: () => ShoppingUnit.piece,
            );
            completedIndex = 3;
          }
          
          final completed = fields.length > completedIndex
              ? fields[completedIndex].trim().toLowerCase() == 'yes' || 
                fields[completedIndex].trim() == '1'
              : false;

          items.add(ShoppingItem(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            name: name,
            quantity: quantity,
            unit: unit,
            addedBy: 'imported',
            isCompleted: completed,
          ));
        }
      } catch (e) {
        // Skip invalid lines
        continue;
      }
    }

    if (items.isEmpty) {
      throw Exception('No valid items found in CSV');
    }

    // Extract list name from filename (remove extension and timestamp if present)
    String listName = fileName.replaceAll('.csv', '');
    listName = listName.split('_').where((part) {
      // Remove timestamp-like parts
      return part.length != 13 || int.tryParse(part) == null;
    }).join(' ');

    if (listName.isEmpty) {
      listName = 'Imported List';
    }

    return ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: listName,
      items: items,
      createdAt: DateTime.now(),
    );
  }

  /// Parse a CSV line handling quoted fields
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    StringBuffer currentField = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          currentField.write('"');
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator
        fields.add(currentField.toString());
        currentField.clear();
      } else {
        currentField.write(char);
      }
    }

    // Add last field
    fields.add(currentField.toString());

    return fields;
  }
}

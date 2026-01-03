import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalImageService {
  Future<String> saveImage(File imageFile, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'images'));
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final savedImage = await imageFile.copy(
        path.join(imagesDir.path, fileName),
      );

      return savedImage.path;
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> getImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when deleting
    }
  }

  Future<String> generateFileName(String prefix) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix$timestamp.jpg';
  }
}


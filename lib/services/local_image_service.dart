import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
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

  Future<String> generateFileName(
    String prefix, {
    String extension = '.jpg',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final normalizedExtension =
        extension.startsWith('.') ? extension : '.$extension';
    return '$prefix$timestamp$normalizedExtension';
  }

  Future<bool> saveToGallery(File imageFile) async {
    try {
      await Gal.putImage(imageFile.path, album: 'Todolio');
      return true;
    } on GalException catch (error, stackTrace) {
      debugPrint('Could not save image to the Todolio gallery album: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}

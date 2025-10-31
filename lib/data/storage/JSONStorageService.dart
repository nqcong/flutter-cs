// lib/data/storage/json_storage_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonStorageService {
  static const String _contactsFileName = 'contacts.json';

  // Get the file path for contacts
  Future<String> get _contactsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_contactsFileName';
  }

  // Get the contacts file
  Future<File> get _contactsFile async {
    final path = await _contactsFilePath;
    return File(path);
  }

  // Read JSON data from file
  Future<Map<String, dynamic>> readJson() async {
    try {
      final file = await _contactsFile;

      // If file doesn't exist, return empty structure
      if (!await file.exists()) {
        print('File does not exist, returning empty structure');
        return {
          'contacts': <Map<String, dynamic>>[], // Explicitly typed empty list
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        print('File is empty, returning empty structure');
        return {
          'contacts': <Map<String, dynamic>>[], // Explicitly typed empty list
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      final decoded = json.decode(contents);
      print('Successfully read JSON: ${decoded.toString()}');
      return decoded as Map<String, dynamic>;
    } catch (e) {
      print('Error reading JSON: $e');
      return {
        'contacts': <Map<String, dynamic>>[], // Explicitly typed empty list
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Write JSON data to file
  Future<void> writeJson(Map<String, dynamic> data) async {
    try {
      final file = await _contactsFile;

      // Ensure contacts is a List
      if (data['contacts'] is! List) {
        throw Exception('contacts must be a List');
      }

      // Add timestamp
      data['lastUpdated'] = DateTime.now().toIso8601String();

      // Encode to JSON string
      final jsonString = json.encode(data);
      print('Writing JSON: $jsonString');

      // Write to file
      await file.writeAsString(jsonString, mode: FileMode.write);

      print('Successfully wrote JSON to file');
    } catch (e) {
      print('Error writing JSON: $e');
      print('Data type: ${data.runtimeType}');
      print('Contacts type: ${data['contacts'].runtimeType}');
      throw Exception('Failed to save contacts: $e');
    }
  }

  // Check if file exists
  Future<bool> fileExists() async {
    final file = await _contactsFile;
    return await file.exists();
  }

  // Delete the file
  Future<void> deleteFile() async {
    try {
      final file = await _contactsFile;
      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Get file size
  Future<int> getFileSize() async {
    try {
      final file = await _contactsFile;
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  // Get file path (for debugging)
  Future<String> getFilePath() async {
    return await _contactsFilePath;
  }
}

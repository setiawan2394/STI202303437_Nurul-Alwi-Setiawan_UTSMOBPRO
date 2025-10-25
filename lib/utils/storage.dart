import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class StorageHelper {
  static const String _fileName = 'notes.json';

  // Mendapatkan file penyimpanan di direktori aplikasi
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Memuat semua catatan dari file JSON
  static Future<List<JournalNote>> loadNotes() async {
    try {
      final file = await _getFile();
      if (!(await file.exists())) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return []; // ← CEGAH ERROR decode file kosong

      final data = jsonDecode(content);
      if (data is! List) return []; // ← CEGAH ERROR decode format aneh

      return data
          .map((e) => JournalNote.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  // Menyimpan semua catatan ke file JSON
  static Future<void> saveNotes(List<JournalNote> notes) async {
    try {
      final file = await _getFile();
      final data = jsonEncode(notes.map((e) => e.toJson()).toList());
      await file.writeAsString(data);
    } catch (e) {
      print('Error saving notes: $e');
    }
  }
}

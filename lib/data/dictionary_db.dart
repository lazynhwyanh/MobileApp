import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDb() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dictionary.db');

  if (!await File(path).exists()) {
    final data = await rootBundle.load('assets/dictionary.db');
    final bytes = data.buffer.asUint8List();
    await File(path).writeAsBytes(bytes, flush: true);
  }

  return openDatabase(path);
}

Future<Map<String, dynamic>?> searchWord(String word) async {
  final db = await initDb();

  final result = await db.rawQuery(
    'SELECT mean, phonetic, opposite_word, synsets, related_words FROM javi WHERE word = ? LIMIT 1',
    [word],
  );

  if (result.isNotEmpty) {
    final row = result[0];

    // Parse danh sách nghĩa
    final meanRaw = row['mean'] as String;
    final meanList = jsonDecode(meanRaw) as List;
    final allMean = meanList.map((e) => e['mean'].toString()).toList();

    return {
      'base': word, // 👈 để hiển thị từ đang tra ở đầu
      'mean': allMean, // 👈 list nghĩa
      'phonetic': row['phonetic'] ?? '',
      'opposite': row['opposite_word'] ?? '',
      'synsets': row['synsets'] ?? '',
      'related': row['related_words'] ?? '',
    };
  }

  return null;
}

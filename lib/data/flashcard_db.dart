import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initFlashcardDb() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'flashcards.db');

  // Nếu DB chưa tồn tại thì copy từ assets
  if (!await File(path).exists()) {
    final data = await rootBundle.load('assets/flashcards.db');
    final bytes = data.buffer.asUint8List();
    await File(path).writeAsBytes(bytes, flush: true);
  }

  return openDatabase(path);
}

Future<void> saveFlashcard(Map<String, dynamic> data) async {
  final db = await initFlashcardDb();

  await db.insert('flashcards', {
    'word': data['base'],
    'meaning': (data['mean'] as List).join(', '),
    'phonetic': data['phonetic'],
    'addedAt': DateTime.now().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<bool> isWordInFlashcard(String word) async {
  final db = await initFlashcardDb();
  final result = await db.query(
    'flashcards',
    where: 'word = ?',
    whereArgs: [word],
    limit: 1,
  );
  return result.isNotEmpty;
}

Future<void> deleteFlashcard(String word) async {
  final db = await initFlashcardDb();
  await db.delete('flashcards', where: 'word = ?', whereArgs: [word]);
}

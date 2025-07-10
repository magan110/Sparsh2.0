import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TokenDatabase {
  static final TokenDatabase _instance = TokenDatabase._internal();
  static Database? _database;

  factory TokenDatabase() {
    return _instance;
  }

  TokenDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'token_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tokens(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        token_data TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert a new token record
  Future<int> insertToken(String token, Map<String, dynamic> tokenData) async {
    final db = await database;

    // Check if token already exists
    final List<Map<String, dynamic>> existingTokens = await db.query(
      'tokens',
      where: 'token = ?',
      whereArgs: [token],
    );

    if (existingTokens.isNotEmpty) {
      // Token already exists, update it
      return await db.update(
        'tokens',
        {'token_data': jsonEncode(tokenData), 'timestamp': DateTime.now().toIso8601String()},
        where: 'token = ?',
        whereArgs: [token],
      );
    } else {
      // Insert new token
      return await db.insert('tokens', {
        'token': token,
        'token_data': jsonEncode(tokenData),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Insert multiple tokens at once
  Future<void> insertTokens(List<Map<String, dynamic>> tokens) async {
    final db = await database;

    for (final tokenData in tokens) {
      try {
        // Make sure token has required fields
        if (tokenData['token'] == null || tokenData['token'].toString().isEmpty) {
          debugPrint('Skipping token with missing token field: $tokenData');
          continue;
        }

        // Check if token already exists
        final List<Map<String, dynamic>> existingTokens = await db.query(
          'tokens',
          where: 'token = ?',
          whereArgs: [tokenData['token'].toString()],
        );

        if (existingTokens.isEmpty) {
          // Only insert if token doesn't exist
          debugPrint('Inserting new token: ${tokenData['token']}');
          await db.insert('tokens', {
            'token': tokenData['token'].toString(),
            'token_data': jsonEncode(tokenData),
            'timestamp': DateTime.now().toIso8601String(),
          });
        } else {
          // Update existing token
          debugPrint('Updating existing token: ${tokenData['token']}');
          await db.update(
            'tokens',
            {'token_data': jsonEncode(tokenData), 'timestamp': DateTime.now().toIso8601String()},
            where: 'token = ?',
            whereArgs: [tokenData['token'].toString()],
          );
        }
      } catch (e) {
        debugPrint('Error inserting/updating token: $e');
        debugPrint('Token data: $tokenData');
      }
    }
  }

  // Get all tokens
  Future<List<String>> getAllTokens() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tokens');

    return List.generate(maps.length, (i) {
      return maps[i]['token'] as String;
    });
  }

  // Get all token data
  Future<List<Map<String, dynamic>>> getAllTokenData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tokens');

    return List.generate(maps.length, (i) {
      return {
        'token': maps[i]['token'] as String,
        'tokenData': jsonDecode(maps[i]['token_data'] as String),
        'timestamp': maps[i]['timestamp'] as String,
      };
    });
  }

  // Delete a token
  Future<int> deleteToken(String token) async {
    final db = await database;
    return await db.delete('tokens', where: 'token = ?', whereArgs: [token]);
  }

  // Delete all tokens
  Future<int> deleteAllTokens() async {
    final db = await database;
    return await db.delete('tokens');
  }

  // Get token count
  Future<int> getTokenCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tokens');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

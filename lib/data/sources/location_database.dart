// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:geolocator/geolocator.dart';
//
// class LocationDatabase {
//   static final LocationDatabase _instance = LocationDatabase._internal();
//   static Database? _database;
//
//   factory LocationDatabase() {
//     return _instance;
//   }
//
//   LocationDatabase._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'location_database.db');
//     return await openDatabase(path, version: 1, onCreate: _createDb);
//   }
//
//   Future<void> _createDb(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE location_data(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         latitude REAL NOT NULL,
//         longitude REAL NOT NULL,
//         accuracy REAL NOT NULL,
//         timestamp TEXT NOT NULL
//       )
//     ''');
//   }
//
//   // Insert a new location record
//   Future<int> insertLocation(Position position) async {
//     final db = await database;
//     return await db.insert('location_data', {
//       'latitude': position.latitude,
//       'longitude': position.longitude,
//       'accuracy': position.accuracy,
//       'timestamp': DateTime.now().toIso8601String(),
//     });
//   }
//
//   // Get all location records (all are unsynced since we delete after syncing)
//   Future<List<Map<String, dynamic>>> getUnsyncedLocations() async {
//     final db = await database;
//     return await db.query('location_data', orderBy: 'timestamp ASC');
//   }
//
//   // Delete a location record after it has been synced
//   Future<int> deleteLocation(int id) async {
//     final db = await database;
//     return await db.delete('location_data', where: 'id = ?', whereArgs: [id]);
//   }
//
//   // Get the count of all locations (all are unsynced since we delete after syncing)
//   Future<int> getUnsyncedCount() async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) as count FROM location_data',
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }
//
//   // Get the total count of locations
//   Future<int> getTotalCount() async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) as count FROM location_data',
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }
//
//   // Get the most recently stored location
//   Future<Map<String, dynamic>?> getLastLocation() async {
//     final db = await database;
//     final results = await db.query(
//       'location_data',
//       orderBy: 'timestamp DESC',
//       limit: 1,
//     );
//
//     if (results.isNotEmpty) {
//       return results.first;
//     }
//     return null;
//   }
//
//   // Delete all location records from the database
//   Future<int> deleteAllLocations() async {
//     final db = await database;
//     return await db.delete('location_data');
//   }
// }

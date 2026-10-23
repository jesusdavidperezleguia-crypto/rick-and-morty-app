
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'rick_and_morty.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            character_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            image TEXT NOT NULL,
            status TEXT,
            species TEXT,
            gender TEXT,
            origin_name TEXT,
            location_name TEXT,
            saved_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE saved_episodes (
            episode_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            episode_code TEXT NOT NULL,
            air_date TEXT,
            saved_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE watch_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            episode_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            episode_code TEXT NOT NULL,
            watched_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // FAVORITOS

  Future<bool> isFavorite(int characterId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'character_id = ?',
      whereArgs: [characterId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> saveFavorite({
    required int id,
    required String name,
    required String image,
    String? status,
    String? species,
    String? gender,
    String? originName,
    String? locationName,
  }) async {
    final db = await database;

    await db.insert(
      'favorites',
      {
        'character_id': id,
        'name': name,
        'image': image,
        'status': status,
        'species': species,
        'gender': gender,
        'origin_name': originName,
        'location_name': locationName,
        'saved_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int characterId) async {
    final db = await database;

    await db.delete(
      'favorites',
      where: 'character_id = ?',
      whereArgs: [characterId],
    );
  }

  Future<List<Map<String, Object?>>> getFavorites() async {
    final db = await database;

    return db.query(
      'favorites',
      orderBy: 'saved_at DESC',
    );
  }

  // EPISODIOS GUARDADOS

  Future<bool> isEpisodeSaved(int episodeId) async {
    final db = await database;

    final result = await db.query(
      'saved_episodes',
      where: 'episode_id = ?',
      whereArgs: [episodeId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> saveEpisode({
    required int id,
    required String name,
    required String episodeCode,
    String? airDate,
  }) async {
    final db = await database;

    await db.insert(
      'saved_episodes',
      {
        'episode_id': id,
        'name': name,
        'episode_code': episodeCode,
        'air_date': airDate,
        'saved_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSavedEpisode(int episodeId) async {
    final db = await database;

    await db.delete(
      'saved_episodes',
      where: 'episode_id = ?',
      whereArgs: [episodeId],
    );
  }

  Future<List<Map<String, Object?>>> getSavedEpisodes() async {
    final db = await database;

    return db.query(
      'saved_episodes',
      orderBy: 'saved_at DESC',
    );
  }

  // HISTORIAL DE REPRODUCCION

  Future<void> addWatchHistory({
    required int episodeId,
    required String name,
    required String episodeCode,
  }) async {
    final db = await database;

    await db.insert(
      'watch_history',
      {
        'episode_id': episodeId,
        'name': name,
        'episode_code': episodeCode,
        'watched_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, Object?>>> getWatchHistory({
    int limit = 100,
  }) async {
    final db = await database;

    return db.query(
      'watch_history',
      orderBy: 'watched_at DESC',
      limit: limit,
    );
  }

  Future<void> deleteHistoryEntry(int historyId) async {
    final db = await database;

    await db.delete(
      'watch_history',
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<void> clearWatchHistory() async {
    final db = await database;
    await db.delete('watch_history');
  }
}

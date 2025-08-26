import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class DatabaseHelper {

  // 私有构造函数
  DatabaseHelper._internal();
  // 单例模式
  static DatabaseHelper? _instance;
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Database? _database;
  static const String _databaseName = 'novel_app.db';
  static const int _databaseVersion = 1;

  // 获取数据库实例
  Future<Database> get database async {
    if (kIsWeb) {
      // Web环境暂时不支持数据库，抛出异常
      throw UnsupportedError('Web环境暂时不支持本地数据库功能');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        // Web环境：这个方法不应该被调用
        throw UnsupportedError('Web环境不支持数据库初始化');
      }
      
      // 移动端环境：使用文档目录
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, _databaseName);
      Logger.info('移动端环境：初始化数据库: $path');
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      Logger.error('数据库初始化失败', e);
      rethrow;
    }
  }

  // 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    try {
      Logger.info('创建数据库表 v$version');
      
      // 创建用户表
      await _createUserTable(db);
      
      // 创建小说表
      await _createNovelTable(db);
      
      // 创建章节表
      await _createChapterTable(db);
      
      // 创建书架表
      await _createBookshelfTable(db);
      
      // 创建阅读进度表
      await _createReadingProgressTable(db);
      
      // 创建书签表
      await _createBookmarkTable(db);
      
      // 创建缓存表
      await _createCacheTable(db);
      
      // 创建搜索历史表
      await _createSearchHistoryTable(db);
      
      Logger.info('数据库表创建完成');
    } catch (e) {
      Logger.error('创建数据库表失败', e);
      rethrow;
    }
  }

  // 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('升级数据库: $oldVersion -> $newVersion');
    
    // 根据版本进行升级
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _upgradeToVersion(db, version);
    }
  }

  // 数据库打开时的回调
  Future<void> _onOpen(Database db) async {
    Logger.debug('DATABASE', '数据库已打开');
    
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
    
    // 设置WAL模式以提高并发性能
    await db.execute('PRAGMA journal_mode = WAL');
  }

  // ==================== 表创建方法 ====================

  // 创建用户表
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        username TEXT,
        email TEXT,
        avatar TEXT,
        nickname TEXT,
        gender INTEGER,
        birthday TEXT,
        phone TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_users_user_id ON users(user_id)');
  }

  // 创建小说表
  Future<void> _createNovelTable(Database db) async {
    await db.execute('''
      CREATE TABLE novels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        novel_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        author TEXT,
        description TEXT,
        cover_url TEXT,
        category TEXT,
        tags TEXT,
        status INTEGER DEFAULT 0,
        word_count INTEGER DEFAULT 0,
        chapter_count INTEGER DEFAULT 0,
        rating REAL DEFAULT 0.0,
        rating_count INTEGER DEFAULT 0,
        is_vip INTEGER DEFAULT 0,
        is_finished INTEGER DEFAULT 0,
        last_update_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_novels_novel_id ON novels(novel_id)');
    await db.execute('CREATE INDEX idx_novels_category ON novels(category)');
    await db.execute('CREATE INDEX idx_novels_status ON novels(status)');
  }

  // 创建章节表
  Future<void> _createChapterTable(Database db) async {
    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id TEXT UNIQUE NOT NULL,
        novel_id TEXT NOT NULL,
        title TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        content TEXT,
        word_count INTEGER DEFAULT 0,
        is_vip INTEGER DEFAULT 0,
        is_cached INTEGER DEFAULT 0,
        publish_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (novel_id) REFERENCES novels(novel_id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('CREATE INDEX idx_chapters_chapter_id ON chapters(chapter_id)');
    await db.execute('CREATE INDEX idx_chapters_novel_id ON chapters(novel_id)');
    await db.execute('CREATE INDEX idx_chapters_number ON chapters(novel_id, chapter_number)');
  }

  // 创建书架表
  Future<void> _createBookshelfTable(Database db) async {
    await db.execute('''
      CREATE TABLE bookshelf (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        novel_id TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        last_read_at INTEGER,
        sort_order INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        UNIQUE(user_id, novel_id),
        FOREIGN KEY (novel_id) REFERENCES novels(novel_id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('CREATE INDEX idx_bookshelf_user_id ON bookshelf(user_id)');
    await db.execute('CREATE INDEX idx_bookshelf_novel_id ON bookshelf(novel_id)');
  }

  // 创建阅读进度表
  Future<void> _createReadingProgressTable(Database db) async {
    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        novel_id TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        progress_percent REAL DEFAULT 0.0,
        reading_position INTEGER DEFAULT 0,
        total_reading_time INTEGER DEFAULT 0,
        last_read_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(user_id, novel_id),
        FOREIGN KEY (novel_id) REFERENCES novels(novel_id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('CREATE INDEX idx_reading_progress_user_id ON reading_progress(user_id)');
    await db.execute('CREATE INDEX idx_reading_progress_novel_id ON reading_progress(novel_id)');
  }

  // 创建书签表
  Future<void> _createBookmarkTable(Database db) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        novel_id TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        content_position INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (novel_id) REFERENCES novels(novel_id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id)');
    await db.execute('CREATE INDEX idx_bookmarks_novel_id ON bookmarks(novel_id)');
    await db.execute('CREATE INDEX idx_bookmarks_chapter_id ON bookmarks(chapter_id)');
  }

  // 创建缓存表
  Future<void> _createCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cache_key TEXT UNIQUE NOT NULL,
        cache_data TEXT NOT NULL,
        cache_type TEXT,
        expire_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_cache_key ON cache(cache_key)');
    await db.execute('CREATE INDEX idx_cache_expire ON cache(expire_time)');
  }

  // 创建搜索历史表
  Future<void> _createSearchHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        keyword TEXT NOT NULL,
        search_count INTEGER DEFAULT 1,
        last_search_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE(user_id, keyword)
      )
    ''');
    
    await db.execute('CREATE INDEX idx_search_history_user_id ON search_history(user_id)');
    await db.execute('CREATE INDEX idx_search_history_keyword ON search_history(keyword)');
  }

  // ==================== 版本升级方法 ====================

  Future<void> _upgradeToVersion(Database db, int version) async {
    Logger.info('升级到版本 $version');
    
    switch (version) {
      case 2:
        // 版本2的升级逻辑
        break;
      case 3:
        // 版本3的升级逻辑
        break;
      default:
        break;
    }
  }

  // ==================== 通用数据库操作方法 ====================

  // 插入数据
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final Database db = await database;
      final int now = DateTime.now().millisecondsSinceEpoch;
      
      data['created_at'] = now;
      data['updated_at'] = now;
      
      final int id = await db.insert(table, data);
      Logger.database('INSERT', table, data);
      return id;
    } catch (e) {
      Logger.error('数据插入失败: $table', e);
      rethrow;
    }
  }

  // 批量插入数据
  Future<void> insertBatch(String table, List<Map<String, dynamic>> dataList) async {
    try {
      final Database db = await database;
      final Batch batch = db.batch();
      final int now = DateTime.now().millisecondsSinceEpoch;
      
      for (final Map<String, dynamic> data in dataList) {
        data['created_at'] = now;
        data['updated_at'] = now;
        batch.insert(table, data);
      }
      
      await batch.commit(noResult: true);
      Logger.database('INSERT_BATCH', table, <String, dynamic>{'count': dataList.length});
    } catch (e) {
      Logger.error('批量数据插入失败: $table', e);
      rethrow;
    }
  }

  // 更新数据
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final Database db = await database;
      data['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      
      final int count = await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
      
      Logger.database('UPDATE', table, <String, dynamic>{
        'data': data,
        'where': where,
        'whereArgs': whereArgs,
        'affected': count,
      });
      
      return count;
    } catch (e) {
      Logger.error('数据更新失败: $table', e);
      rethrow;
    }
  }

  // 删除数据
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final Database db = await database;
      final int count = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      
      Logger.database('DELETE', table, <String, dynamic>{
        'where': where,
        'whereArgs': whereArgs,
        'affected': count,
      });
      
      return count;
    } catch (e) {
      Logger.error('数据删除失败: $table', e);
      rethrow;
    }
  }

  // 查询数据
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> result = await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      
      Logger.database('SELECT', table, <String, dynamic>{
        'where': where,
        'whereArgs': whereArgs,
        'orderBy': orderBy,
        'limit': limit,
        'count': result.length,
      });
      
      return result;
    } catch (e) {
      Logger.error('数据查询失败: $table', e);
      rethrow;
    }
  }

  // 原始SQL查询
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> result = await db.rawQuery(sql, arguments);
      
      Logger.database('RAW_QUERY', 'custom', <String, dynamic>{
        'sql': sql,
        'arguments': arguments,
        'count': result.length,
      });
      
      return result;
    } catch (e) {
      Logger.error('原始SQL查询失败', e);
      rethrow;
    }
  }

  // 原始SQL执行
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    try {
      final Database db = await database;
      final int result = await db.rawInsert(sql, arguments);
      
      Logger.database('RAW_EXECUTE', 'custom', <String, dynamic>{
        'sql': sql,
        'arguments': arguments,
        'result': result,
      });
      
      return result;
    } catch (e) {
      Logger.error('原始SQL执行失败', e);
      rethrow;
    }
  }

  // 事务操作
  Future<T> transaction<T>(Future<T> Function(Transaction) action) async {
    try {
      final Database db = await database;
      return await db.transaction(action);
    } catch (e) {
      Logger.error('事务执行失败', e);
      rethrow;
    }
  }

  // ==================== 数据库维护方法 ====================

  // 清理过期缓存
  Future<void> cleanExpiredCache() async {
    try {
      final int now = DateTime.now().millisecondsSinceEpoch;
      final int count = await delete(
        'cache',
        where: 'expire_time IS NOT NULL AND expire_time < ?',
        whereArgs: <dynamic>[now],
      );
      Logger.info('清理过期缓存: $count条');
    } catch (e) {
      Logger.error('清理过期缓存失败', e);
    }
  }

  // 清理旧的搜索历史
  Future<void> cleanOldSearchHistory([int keepDays = 30]) async {
    try {
      final int cutoffTime = DateTime.now()
          .subtract(Duration(days: keepDays))
          .millisecondsSinceEpoch;
      
      final int count = await delete(
        'search_history',
        where: 'last_search_at < ?',
        whereArgs: <dynamic>[cutoffTime],
      );
      Logger.info('清理旧搜索历史: $count条');
    } catch (e) {
      Logger.error('清理旧搜索历史失败', e);
    }
  }

  // 获取数据库信息
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final Database db = await database;
      final String path = db.path;
      final int version = await db.getVersion();
      
      int size = 0;
      if (!kIsWeb) {
        // 只在非Web环境中获取文件大小
        final File dbFile = File(path);
        size = await dbFile.length();
      }
      
      // 获取各表记录数
      final List<String> tables = <String>['users', 'novels', 'chapters', 'bookshelf', 
                     'reading_progress', 'bookmarks', 'cache', 'search_history'];
      final Map<String, int> tableCounts = <String, int>{};
      
      for (final String table in tables) {
        try {
          final List<Map<String, dynamic>> result = await rawQuery('SELECT COUNT(*) as count FROM $table');
          tableCounts[table] = result.first['count'] as int;
        } catch (e) {
          tableCounts[table] = 0;
        }
      }
      
      return <String, dynamic>{
        'path': path,
        'version': version,
        'size': size,
        'tables': tableCounts,
        'isWeb': kIsWeb,
      };
    } catch (e) {
      Logger.error('获取数据库信息失败', e);
      rethrow;
    }
  }

  // 备份数据库
  Future<String> backupDatabase() async {
    try {
      if (kIsWeb) {
        // Web环境不支持文件备份
        throw UnsupportedError('Web环境不支持数据库备份');
      }
      
      final Database db = await database;
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String backupPath = join(documentsDir.path, 'backup_${timestamp}_$_databaseName');
      
      final File dbFile = File(db.path);
      await dbFile.copy(backupPath);
      
      Logger.info('数据库备份完成: $backupPath');
      return backupPath;
    } catch (e) {
      Logger.error('数据库备份失败', e);
      rethrow;
    }
  }

  // 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      Logger.info('数据库已关闭');
    }
  }

  // 删除数据库
  Future<void> deleteDatabase() async {
    try {
      await close();
      
      if (kIsWeb) {
        // Web环境：直接删除数据库
        await databaseFactory.deleteDatabase(_databaseName);
        Logger.warning('Web环境：数据库已删除');
      } else {
        // 移动端环境：使用文档目录路径
        final Directory documentsDirectory = await getApplicationDocumentsDirectory();
        final String path = join(documentsDirectory.path, _databaseName);
        await databaseFactory.deleteDatabase(path);
        Logger.warning('移动端环境：数据库已删除: $path');
      }
    } catch (e) {
      Logger.error('删除数据库失败', e);
      rethrow;
    }
  }
}
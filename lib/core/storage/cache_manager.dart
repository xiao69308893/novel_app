import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import '../utils/preferences_helper.dart';
import '../constants/app_constants.dart';
import 'database_helper.dart';

/// 缓存类型枚举
enum CacheType {
  memory,    // 内存缓存
  disk,      // 磁盘缓存
  database,  // 数据库缓存
  image,     // 图片缓存
  file,      // 文件缓存
}

/// 缓存项
class CacheItem<T> {
  final String key;
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int? maxAge; // 秒
  final Map<String, dynamic>? metadata;

  const CacheItem({
    required this.key,
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.maxAge,
    this.metadata,
  });

  /// 是否已过期
  bool get isExpired {
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    if (maxAge != null) {
      return DateTime.now().isAfter(createdAt.add(Duration(seconds: maxAge!)));
    }
    return false;
  }

  /// 剩余有效时间（秒）
  int get remainingSeconds {
    if (expiresAt != null) {
      return expiresAt!.difference(DateTime.now()).inSeconds;
    }
    if (maxAge != null) {
      final expireTime = createdAt.add(Duration(seconds: maxAge!));
      return expireTime.difference(DateTime.now()).inSeconds;
    }
    return -1;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'created_at': createdAt.millisecondsSinceEpoch,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
      'max_age': maxAge,
      'metadata': metadata,
    };
  }

  /// 从JSON创建
  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      key: json['key'] as String,
      data: json['data'] as T,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      expiresAt: json['expires_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int)
          : null,
      maxAge: json['max_age'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 缓存统计信息
class CacheStats {
  final int totalItems;
  final int memoryItems;
  final int diskItems;
  final int databaseItems;
  final int totalSize; // 字节
  final int hitCount;
  final int missCount;
  final double hitRate;

  const CacheStats({
    required this.totalItems,
    required this.memoryItems,
    required this.diskItems,
    required this.databaseItems,
    required this.totalSize,
    required this.hitCount,
    required this.missCount,
    required this.hitRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'memory_items': memoryItems,
      'disk_items': diskItems,
      'database_items': databaseItems,
      'total_size': totalSize,
      'hit_count': hitCount,
      'miss_count': missCount,
      'hit_rate': hitRate,
    };
  }
}

/// 通用缓存管理器
class CacheManager {
  // 单例模式
  static CacheManager? _instance;
  static CacheManager get instance {
    _instance ??= CacheManager._internal();
    return _instance!;
  }

  // 内存缓存
  final Map<String, CacheItem> _memoryCache = {};
  
  // 磁盘缓存目录
  Directory? _cacheDirectory;
  
  // 统计信息
  int _hitCount = 0;
  int _missCount = 0;
  
  // 配置
  late final CacheConfig _config;

  // 私有构造函数
  CacheManager._internal() {
    _config = CacheConfig();
    _initializeCache();
  }

  /// 初始化缓存
  Future<void> _initializeCache() async {
    try {
      // 初始化磁盘缓存目录
      final tempDir = await getTemporaryDirectory();
      _cacheDirectory = Directory(path.join(tempDir.path, 'cache'));
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      // 清理过期缓存
      await _cleanExpiredCache();
      
      // 加载统计信息
      _loadStats();
      
      Logger.info('缓存管理器初始化完成');
    } catch (e) {
      Logger.error('缓存管理器初始化失败', e);
    }
  }

  // ==================== 内存缓存操作 ====================

  /// 存储到内存缓存
  Future<void> putMemory<T>(
    String key,
    T data, {
    Duration? duration,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final item = CacheItem<T>(
        key: key,
        data: data,
        createdAt: DateTime.now(),
        expiresAt: expiresAt ?? (duration != null ? DateTime.now().add(duration) : null),
        maxAge: duration?.inSeconds,
        metadata: metadata,
      );

      _memoryCache[key] = item;
      
      // 检查内存缓存大小限制
      await _checkMemoryCacheSize();
      
      Logger.cache('PUT_MEMORY', key);
    } catch (e) {
      Logger.error('内存缓存存储失败: $key', e);
    }
  }

  /// 从内存缓存获取
  T? getMemory<T>(String key) {
    try {
      final item = _memoryCache[key];
      if (item == null) {
        _missCount++;
        return null;
      }

      if (item.isExpired) {
        _memoryCache.remove(key);
        _missCount++;
        Logger.cache('EXPIRED_MEMORY', key);
        return null;
      }

      _hitCount++;
      Logger.cache('HIT_MEMORY', key);
      return item.data as T;
    } catch (e) {
      Logger.error('内存缓存获取失败: $key', e);
      _missCount++;
      return null;
    }
  }

  /// 从内存缓存删除
  Future<bool> removeMemory(String key) async {
    try {
      final removed = _memoryCache.remove(key) != null;
      if (removed) {
        Logger.cache('REMOVE_MEMORY', key);
      }
      return removed;
    } catch (e) {
      Logger.error('内存缓存删除失败: $key', e);
      return false;
    }
  }

  // ==================== 磁盘缓存操作 ====================

  /// 存储到磁盘缓存
  Future<void> putDisk<T>(
    String key,
    T data, {
    Duration? duration,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_cacheDirectory == null) return;

      final item = CacheItem<T>(
        key: key,
        data: data,
        createdAt: DateTime.now(),
        expiresAt: expiresAt ?? (duration != null ? DateTime.now().add(duration) : null),
        maxAge: duration?.inSeconds,
        metadata: metadata,
      );

      final file = File(path.join(_cacheDirectory!.path, '${_sanitizeKey(key)}.cache'));
      final jsonData = json.encode(item.toJson());
      await file.writeAsString(jsonData);

      Logger.cache('PUT_DISK', key);
    } catch (e) {
      Logger.error('磁盘缓存存储失败: $key', e);
    }
  }

  /// 从磁盘缓存获取
  Future<T?> getDisk<T>(String key) async {
    try {
      if (_cacheDirectory == null) {
        _missCount++;
        return null;
      }

      final file = File(path.join(_cacheDirectory!.path, '${_sanitizeKey(key)}.cache'));
      if (!await file.exists()) {
        _missCount++;
        return null;
      }

      final jsonData = await file.readAsString();
      final itemJson = json.decode(jsonData) as Map<String, dynamic>;
      final item = CacheItem<T>.fromJson(itemJson);

      if (item.isExpired) {
        await file.delete();
        _missCount++;
        Logger.cache('EXPIRED_DISK', key);
        return null;
      }

      _hitCount++;
      Logger.cache('HIT_DISK', key);
      return item.data;
    } catch (e) {
      Logger.error('磁盘缓存获取失败: $key', e);
      _missCount++;
      return null;
    }
  }

  /// 从磁盘缓存删除
  Future<bool> removeDisk(String key) async {
    try {
      if (_cacheDirectory == null) return false;

      final file = File(path.join(_cacheDirectory!.path, '${_sanitizeKey(key)}.cache'));
      if (await file.exists()) {
        await file.delete();
        Logger.cache('REMOVE_DISK', key);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('磁盘缓存删除失败: $key', e);
      return false;
    }
  }

  // ==================== 数据库缓存操作 ====================

  /// 存储到数据库缓存
  Future<void> putDatabase<T>(
    String key,
    T data, {
    Duration? duration,
    DateTime? expiresAt,
    String? type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final db = DatabaseHelper.instance;
      final jsonData = json.encode(data);
      final expireTime = expiresAt?.millisecondsSinceEpoch ?? 
                        (duration != null ? DateTime.now().add(duration).millisecondsSinceEpoch : null);

      final existingCache = await db.query(
        'cache',
        where: 'cache_key = ?',
        whereArgs: [key],
      );

      final cacheData = {
        'cache_key': key,
        'cache_data': jsonData,
        'cache_type': type ?? 'general',
        'expire_time': expireTime,
      };

      if (existingCache.isNotEmpty) {
        await db.update(
          'cache',
          cacheData,
          where: 'cache_key = ?',
          whereArgs: [key],
        );
      } else {
        await db.insert('cache', cacheData);
      }

      Logger.cache('PUT_DATABASE', key);
    } catch (e) {
      Logger.error('数据库缓存存储失败: $key', e);
    }
  }

  /// 从数据库缓存获取
  Future<T?> getDatabase<T>(String key) async {
    try {
      final db = DatabaseHelper.instance;
      final result = await db.query(
        'cache',
        where: 'cache_key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) {
        _missCount++;
        return null;
      }

      final cacheData = result.first;
      final expireTime = cacheData['expire_time'] as int?;
      
      // 检查是否过期
      if (expireTime != null && DateTime.now().millisecondsSinceEpoch > expireTime) {
        await db.delete('cache', where: 'cache_key = ?', whereArgs: [key]);
        _missCount++;
        Logger.cache('EXPIRED_DATABASE', key);
        return null;
      }

      final jsonData = cacheData['cache_data'] as String;
      final data = json.decode(jsonData) as T;

      _hitCount++;
      Logger.cache('HIT_DATABASE', key);
      return data;
    } catch (e) {
      Logger.error('数据库缓存获取失败: $key', e);
      _missCount++;
      return null;
    }
  }

  /// 从数据库缓存删除
  Future<bool> removeDatabase(String key) async {
    try {
      final db = DatabaseHelper.instance;
      final count = await db.delete(
        'cache',
        where: 'cache_key = ?',
        whereArgs: [key],
      );
      
      if (count > 0) {
        Logger.cache('REMOVE_DATABASE', key);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('数据库缓存删除失败: $key', e);
      return false;
    }
  }

  // ==================== 统一缓存接口 ====================

  /// 通用缓存存储
  Future<void> put<T>(
    String key,
    T data, {
    CacheType type = CacheType.memory,
    Duration? duration,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    switch (type) {
      case CacheType.memory:
        await putMemory(key, data, duration: duration, expiresAt: expiresAt, metadata: metadata);
        break;
      case CacheType.disk:
        await putDisk(key, data, duration: duration, expiresAt: expiresAt, metadata: metadata);
        break;
      case CacheType.database:
        await putDatabase(key, data, duration: duration, expiresAt: expiresAt);
        break;
      default:
        await putMemory(key, data, duration: duration, expiresAt: expiresAt, metadata: metadata);
        break;
    }
  }

  /// 通用缓存获取
  Future<T?> get<T>(
    String key, {
    CacheType type = CacheType.memory,
  }) async {
    switch (type) {
      case CacheType.memory:
        return getMemory<T>(key);
      case CacheType.disk:
        return await getDisk<T>(key);
      case CacheType.database:
        return await getDatabase<T>(key);
      default:
        return getMemory<T>(key);
    }
  }

  /// 通用缓存删除
  Future<bool> remove(
    String key, {
    CacheType type = CacheType.memory,
  }) async {
    switch (type) {
      case CacheType.memory:
        return await removeMemory(key);
      case CacheType.disk:
        return await removeDisk(key);
      case CacheType.database:
        return await removeDatabase(key);
      default:
        return await removeMemory(key);
    }
  }

  /// 多级缓存获取（先内存，再磁盘，最后数据库）
  Future<T?> getMultiLevel<T>(String key) async {
    // 先从内存缓存获取
    T? data = getMemory<T>(key);
    if (data != null) return data;

    // 再从磁盘缓存获取
    data = await getDisk<T>(key);
    if (data != null) {
      // 回写到内存缓存
      await putMemory(key, data, duration: _config.defaultDuration);
      return data;
    }

    // 最后从数据库缓存获取
    data = await getDatabase<T>(key);
    if (data != null) {
      // 回写到内存和磁盘缓存
      await putMemory(key, data, duration: _config.defaultDuration);
      await putDisk(key, data, duration: _config.defaultDuration);
      return data;
    }

    return null;
  }

  // ==================== 缓存维护 ====================

  /// 清理过期缓存
  Future<void> _cleanExpiredCache() async {
    try {
      // 清理内存缓存
      final expiredMemoryKeys = _memoryCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();
      
      for (final key in expiredMemoryKeys) {
        _memoryCache.remove(key);
      }

      // 清理磁盘缓存
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        final files = await _cacheDirectory!.list().toList();
        for (final file in files) {
          if (file is File && file.path.endsWith('.cache')) {
            try {
              final jsonData = await file.readAsString();
              final itemJson = json.decode(jsonData) as Map<String, dynamic>;
              final item = CacheItem.fromJson(itemJson);
              
              if (item.isExpired) {
                await file.delete();
              }
            } catch (e) {
              // 如果读取失败，删除该文件
              await file.delete();
            }
          }
        }
      }

      // 清理数据库缓存
      await DatabaseHelper.instance.cleanExpiredCache();

      Logger.info('过期缓存清理完成');
    } catch (e) {
      Logger.error('清理过期缓存失败', e);
    }
  }

  /// 检查内存缓存大小
  Future<void> _checkMemoryCacheSize() async {
    if (_memoryCache.length > _config.maxMemoryItems) {
      // 按创建时间排序，删除最旧的缓存项
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final removeCount = _memoryCache.length - _config.maxMemoryItems;
      for (int i = 0; i < removeCount; i++) {
        _memoryCache.remove(sortedEntries[i].key);
      }
      
      Logger.debug('CACHE', '清理内存缓存: $removeCount项');
    }
  }

  /// 清空所有缓存
  Future<void> clearAll() async {
    try {
      // 清空内存缓存
      _memoryCache.clear();

      // 清空磁盘缓存
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }

      // 清空数据库缓存
      await DatabaseHelper.instance.delete('cache');

      Logger.warning('所有缓存已清空');
    } catch (e) {
      Logger.error('清空缓存失败', e);
    }
  }

  /// 获取缓存统计信息
  Future<CacheStats> getStats() async {
    try {
      final memoryItems = _memoryCache.length;
      
      int diskItems = 0;
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        final files = await _cacheDirectory!.list().toList();
        diskItems = files.where((file) => file.path.endsWith('.cache')).length;
      }

      final db = DatabaseHelper.instance;
      final dbResult = await db.rawQuery('SELECT COUNT(*) as count FROM cache');
      final databaseItems = dbResult.first['count'] as int;

      final totalItems = memoryItems + diskItems + databaseItems;
      final totalRequests = _hitCount + _missCount;
      final hitRate = totalRequests > 0 ? _hitCount / totalRequests : 0.0;

      return CacheStats(
        totalItems: totalItems,
        memoryItems: memoryItems,
        diskItems: diskItems,
        databaseItems: databaseItems,
        totalSize: await _calculateTotalSize(),
        hitCount: _hitCount,
        missCount: _missCount,
        hitRate: hitRate,
      );
    } catch (e) {
      Logger.error('获取缓存统计失败', e);
      return const CacheStats(
        totalItems: 0,
        memoryItems: 0,
        diskItems: 0,
        databaseItems: 0,
        totalSize: 0,
        hitCount: 0,
        missCount: 0,
        hitRate: 0.0,
      );
    }
  }

  /// 计算总缓存大小
  Future<int> _calculateTotalSize() async {
    int totalSize = 0;

    try {
      // 计算磁盘缓存大小
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        final files = await _cacheDirectory!.list().toList();
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }

      // 内存缓存大小估算
      for (final item in _memoryCache.values) {
        totalSize += json.encode(item.toJson()).length;
      }
    } catch (e) {
      Logger.error('计算缓存大小失败', e);
    }

    return totalSize;
  }

  /// 清理键名（用于文件名）
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^\w\-_.]'), '_');
  }

  /// 加载统计信息
  void _loadStats() {
    _hitCount = PreferencesHelper.getInt('cache_hit_count', 0);
    _missCount = PreferencesHelper.getInt('cache_miss_count', 0);
  }

  /// 保存统计信息
  Future<void> _saveStats() async {
    await PreferencesHelper.setInt('cache_hit_count', _hitCount);
    await PreferencesHelper.setInt('cache_miss_count', _missCount);
  }

  /// 重置统计信息
  Future<void> resetStats() async {
    _hitCount = 0;
    _missCount = 0;
    await _saveStats();
    Logger.info('缓存统计信息已重置');
  }
}

/// 缓存配置
class CacheConfig {
  final Duration defaultDuration;
  final int maxMemoryItems;
  final int maxDiskSize; // MB
  final bool enableAutoClean;
  final Duration cleanInterval;

  const CacheConfig({
    this.defaultDuration = const Duration(hours: 1),
    this.maxMemoryItems = 100,
    this.maxDiskSize = 100,
    this.enableAutoClean = true,
    this.cleanInterval = const Duration(hours: 6),
  });
}
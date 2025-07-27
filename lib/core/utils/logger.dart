import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Logger {
  // 私有构造函数
  Logger._internal();
  
  static Logger? _instance;
  static Logger get instance {
    _instance ??= Logger._internal();
    return _instance!;
  }
  
  late logger.Logger _logger;
  
  // 日志级别枚举
  static const int levelVerbose = 500;
  static const int levelDebug = 700;
  static const int levelInfo = 800;
  static const int levelWarning = 900;
  static const int levelError = 1000;
  static const int levelSevere = 1200;
  
  // 初始化日志系统
  static Future<void> init() async {
    final instance = Logger.instance;
    
    // 创建日志输出器
    final outputs = <LogOutput>[];
    
    // 在调试模式下添加控制台输出
    if (kDebugMode) {
      outputs.add(ConsoleOutput());
    }
    
    // 在生产模式下添加文件输出
    if (kReleaseMode) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final logFile = File('${directory.path}/app_logs.txt');
        outputs.add(FileOutput(file: logFile));
      } catch (e) {
        // 如果无法创建文件输出，则仅使用控制台输出
        if (kDebugMode) {
          print('无法创建日志文件: $e');
        }
      }
    }
    
    instance._logger = logger.Logger(
      printer: CustomLogPrinter(),
      output: MultiOutput(outputs),
      level: kDebugMode ? logger.Level.debug : logger.Level.info,
    );
    
    info('日志系统初始化完成');
  }
  
  // 详细日志 (仅在调试模式下输出)
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      instance._logger.t(message, error: error, stackTrace: stackTrace);
      developer.log(
        message,
        name: 'VERBOSE',
        level: levelVerbose,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  // 调试日志
  static void debug(String tag, dynamic message) {
    if (kDebugMode) {
      final formattedMessage = '[$tag] $message';
      instance._logger.d(formattedMessage);
      developer.log(
        formattedMessage,
        name: tag,
        level: levelDebug,
      );
    }
  }
  
  // 信息日志
  static void info(String message, [String? tag]) {
    final formattedMessage = tag != null ? '[$tag] $message' : message;
    instance._logger.i(formattedMessage);
    developer.log(
      message,
      name: tag ?? 'INFO',
      level: levelInfo,
    );
  }
  
  // 警告日志
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.w(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'WARNING',
      error: error,
      stackTrace: stackTrace,
      level: levelWarning,
    );
  }
  
  // 错误日志
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.e(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
      level: levelError,
    );
  }
  
  // 严重错误日志
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._logger.f(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      name: 'FATAL',
      error: error,
      stackTrace: stackTrace,
      level: levelSevere,
    );
  }
  
  // 网络请求日志
  static void network(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    String? response,
    Duration? duration,
  }) {
    if (kDebugMode) {
      final logMessage = StringBuffer();
      logMessage.writeln('🌐 网络请求: $method $url');
      
      if (duration != null) {
        logMessage.writeln('⏱️  耗时: ${duration.inMilliseconds}ms');
      }
      
      if (headers != null && headers.isNotEmpty) {
        logMessage.writeln('📝 请求头: ${_formatJson(headers)}');
      }
      
      if (body != null) {
        logMessage.writeln('📤 请求体: ${_formatBody(body)}');
      }
      
      if (statusCode != null) {
        final statusEmoji = _getStatusEmoji(statusCode);
        logMessage.writeln('📊 状态码: $statusEmoji $statusCode');
      }
      
      if (response != null) {
        logMessage.writeln('📥 响应: ${_formatResponse(response)}');
      }
      
      instance._logger.d(logMessage.toString());
    }
  }
  
  // 用户行为日志
  static void userAction(String action, [Map<String, dynamic>? parameters]) {
    final message = parameters != null 
        ? '👤 用户操作: $action, 参数: ${_formatJson(parameters)}'
        : '👤 用户操作: $action';
    
    info(message, 'USER_ACTION');
  }
  
  // 性能日志
  static void performance(String operation, Duration duration, [Map<String, dynamic>? metadata]) {
    final message = StringBuffer();
    message.write('⚡ 性能统计: $operation 耗时 ${duration.inMilliseconds}ms');
    
    if (metadata != null && metadata.isNotEmpty) {
      message.write(', 元数据: ${_formatJson(metadata)}');
    }
    
    info(message.toString(), 'PERFORMANCE');
  }
  
  // 缓存日志
  static void cache(String operation, String key, [String? details]) {
    final message = details != null 
        ? '💾 缓存操作: $operation - $key ($details)'
        : '💾 缓存操作: $operation - $key';
    
    debug('CACHE', message);
  }
  
  // 数据库日志
  static void database(String operation, String table, [Map<String, dynamic>? data]) {
    final message = StringBuffer();
    message.write('🗄️  数据库操作: $operation - $table');
    
    if (data != null && data.isNotEmpty) {
      message.write(', 数据: ${_formatJson(data)}');
    }
    
    debug('DATABASE', message.toString());
  }
  
  // 状态变化日志
  static void stateChange(String from, String to, [String? context]) {
    final message = context != null 
        ? '🔄 状态变化: $from -> $to ($context)'
        : '🔄 状态变化: $from -> $to';
    
    debug('STATE', message);
  }
  
  // 格式化JSON
  static String _formatJson(Map<String, dynamic> json) {
    try {
      return json.toString();
    } catch (e) {
      return json.toString();
    }
  }
  
  // 格式化请求体
  static String _formatBody(dynamic body) {
    if (body == null) return 'null';
    if (body is String) return body.length > 1000 ? '${body.substring(0, 1000)}...' : body;
    if (body is Map || body is List) return _formatJson(body as Map<String, dynamic>);
    return body.toString();
  }
  
  // 格式化响应
  static String _formatResponse(String response) {
    return response.length > 1000 ? '${response.substring(0, 1000)}...' : response;
  }
  
  // 获取状态码对应的emoji
  static String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '↩️';
    if (statusCode >= 400 && statusCode < 500) return '❌';
    if (statusCode >= 500) return '💥';
    return '❓';
  }
}

// 自定义日志打印器
class CustomLogPrinter extends LogPrinter {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  
  @override
  List<String> log(LogEvent event) {
    final time = _dateFormat.format(DateTime.now());
    final level = event.level.name.toUpperCase().padRight(7);
    final message = event.message;
    
    var output = '[$time] [$level] $message';
    
    if (event.error != null) {
      output += '\n错误: ${event.error}';
    }
    
    if (event.stackTrace != null) {
      output += '\n堆栈跟踪:\n${event.stackTrace}';
    }
    
    return [output];
  }
}

// 文件输出器
class FileOutput extends LogOutput {
  final File file;
  IOSink? _sink;
  
  FileOutput({required this.file});
  
  @override
  void init() {
    super.init();
    _sink = file.openWrite(mode: FileMode.append);
  }
  
  @override
  void output(OutputEvent event) {
    if (_sink != null) {
      for (final line in event.lines) {
        _sink!.writeln(line);
      }
      _sink!.flush();
    }
  }
  
  @override
  void destroy() {
    _sink?.close();
    super.destroy();
  }
}

// 多输出器
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;
  
  MultiOutput(this.outputs);
  
  @override
  void init() {
    super.init();
    for (final output in outputs) {
      output.init();
    }
  }
  
  @override
  void output(OutputEvent event) {
    for (final output in outputs) {
      output.output(event);
    }
  }
  
  @override
  void destroy() {
    for (final output in outputs) {
      output.destroy();
    }
    super.destroy();
  }
}
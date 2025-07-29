import 'package:equatable/equatable.dart';

/// 阅读会话
class ReadingSession extends Equatable {
  /// 会话ID
  final String id;
  
  /// 小说ID
  final String novelId;
  
  /// 章节ID
  final String chapterId;
  
  /// 开始时间
  final DateTime startTime;
  
  /// 结束时间
  final DateTime? endTime;
  
  /// 阅读进度（0.0-1.0）
  final double progress;
  
  /// 阅读位置（字符偏移）
  final int position;
  
  /// 阅读时长（秒）
  final int duration;
  
  /// 设备信息
  final String deviceId;
  
  /// 是否同步到云端
  final bool isSynced;

  const ReadingSession({
    required this.id,
    required this.novelId,
    required this.chapterId,
    required this.startTime,
    this.endTime,
    this.progress = 0.0,
    this.position = 0,
    this.duration = 0,
    required this.deviceId,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
        id,
        novelId,
        chapterId,
        startTime,
        endTime,
        progress,
        position,
        duration,
        deviceId,
        isSynced,
      ];

  /// 是否正在进行中
  bool get isActive => endTime == null;

  /// 实际阅读时长
  Duration get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  ReadingSession copyWith({
    String? id,
    String? novelId,
    String? chapterId,
    DateTime? startTime,
    DateTime? endTime,
    double? progress,
    int? position,
    int? duration,
    String? deviceId,
    bool? isSynced,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      progress: progress ?? this.progress,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'chapterId': chapterId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'progress': progress,
      'position': position,
      'duration': duration,
      'deviceId': deviceId,
      'isSynced': isSynced,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      novelId: json['novelId'] as String,
      chapterId: json['chapterId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      position: json['position'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      deviceId: json['deviceId'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}
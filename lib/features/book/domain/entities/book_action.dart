// 小说操作实体
import 'package:equatable/equatable.dart';

enum BookActionType {
  favorite(0, '收藏'),
  unfavorite(1, '取消收藏'),
  download(2, '下载'),
  share(3, '分享'),
  rate(4, '评分'),
  report(5, '举报');

  const BookActionType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static BookActionType fromValue(int? value) => BookActionType.values.firstWhere(
      (BookActionType t) => t.value == value,
      orElse: () => BookActionType.favorite,
    );
}

class BookAction extends Equatable {

  const BookAction({
    required this.type,
    required this.bookId,
    required this.timestamp, this.data,
  });
  final BookActionType type;
  final String bookId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  @override
  List<Object?> get props => <Object?>[type, bookId, data, timestamp];
}
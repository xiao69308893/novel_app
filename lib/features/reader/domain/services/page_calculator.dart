import 'package:flutter/material.dart';
import '../entities/reader_config.dart';

/// 页面计算服务
class PageCalculator {
  /// 计算文本分页
  static List<String> calculatePages({
    required String content,
    required ReaderConfig config,
    required Size screenSize,
  }) {
    if (content.isEmpty) return [];

    // 如果是滚动模式，不需要分页
    if (config.pageMode == PageMode.scroll) {
      return [content];
    }

    // 计算可用区域大小
    final availableWidth = screenSize.width - 
        config.pageMargin.left - config.pageMargin.right;
    final availableHeight = screenSize.height - 
        config.pageMargin.top - config.pageMargin.bottom;

    // 估算每行字符数和每页行数
    final charWidth = config.fontSize * 0.6; // 中文字符大约是字体大小的0.6倍宽
    final lineHeight = config.fontSize * config.lineHeight;
    
    final charsPerLine = (availableWidth / charWidth).floor();
    final linesPerPage = (availableHeight / lineHeight).floor();
    final charsPerPage = charsPerLine * linesPerPage;

    // 分割内容
    final pages = <String>[];
    final paragraphs = content.split('\n');
    String currentPage = '';
    int currentPageLength = 0;

    for (final paragraph in paragraphs) {
      final paragraphLines = _splitParagraphIntoLines(paragraph, charsPerLine);
      
      for (final line in paragraphLines) {
        // 检查是否需要换页
        if (currentPageLength + line.length > charsPerPage && currentPage.isNotEmpty) {
          pages.add(currentPage.trim());
          currentPage = '';
          currentPageLength = 0;
        }
        
        currentPage += line + '\n';
        currentPageLength += line.length + 1; // +1 for newline
      }
    }

    // 添加最后一页
    if (currentPage.isNotEmpty) {
      pages.add(currentPage.trim());
    }

    return pages.isEmpty ? [content] : pages;
  }

  /// 将段落分割成行
  static List<String> _splitParagraphIntoLines(String paragraph, int charsPerLine) {
    if (paragraph.isEmpty) return [''];
    
    final lines = <String>[];
    String currentLine = '';
    
    for (int i = 0; i < paragraph.length; i++) {
      final char = paragraph[i];
      
      // 检查是否需要换行
      if (currentLine.length >= charsPerLine) {
        lines.add(currentLine);
        currentLine = '';
      }
      
      currentLine += char;
    }
    
    // 添加最后一行
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    
    return lines.isEmpty ? [''] : lines;
  }

  /// 根据页码计算在原文中的位置
  static int calculatePositionFromPage({
    required List<String> pages,
    required int page,
  }) {
    if (pages.isEmpty || page < 0 || page >= pages.length) {
      return 0;
    }

    int position = 0;
    for (int i = 0; i < page; i++) {
      position += pages[i].length;
    }
    
    return position;
  }

  /// 根据原文位置计算页码
  static int calculatePageFromPosition({
    required List<String> pages,
    required int position,
  }) {
    if (pages.isEmpty || position <= 0) {
      return 0;
    }

    int currentPosition = 0;
    for (int i = 0; i < pages.length; i++) {
      currentPosition += pages[i].length;
      if (currentPosition >= position) {
        return i;
      }
    }

    return pages.length - 1;
  }

  /// 计算阅读进度百分比
  static double calculateProgress({
    required List<String> pages,
    required int currentPage,
  }) {
    if (pages.isEmpty) return 0.0;
    return (currentPage + 1) / pages.length;
  }

  /// 根据屏幕尺寸和配置估算单页字符数
  static int estimateCharsPerPage({
    required ReaderConfig config,
    required Size screenSize,
  }) {
    final availableWidth = screenSize.width - 
        config.pageMargin.left - config.pageMargin.right;
    final availableHeight = screenSize.height - 
        config.pageMargin.top - config.pageMargin.bottom;

    final charWidth = config.fontSize * 0.6;
    final lineHeight = config.fontSize * config.lineHeight;
    
    final charsPerLine = (availableWidth / charWidth).floor();
    final linesPerPage = (availableHeight / lineHeight).floor();
    
    return charsPerLine * linesPerPage;
  }

  /// 预估阅读时间（分钟）
  static int estimateReadingTime({
    required String content,
    int wordsPerMinute = 300, // 平均阅读速度：每分钟300字
  }) {
    if (content.isEmpty) return 0;
    
    // 中文字符数大致等于单词数
    final wordCount = content.length;
    return (wordCount / wordsPerMinute).ceil();
  }

  /// 计算两个位置之间的文本长度
  static int calculateTextLength({
    required String content,
    required int startPosition,
    required int endPosition,
  }) {
    if (startPosition < 0 || endPosition < 0 || 
        startPosition > content.length || endPosition > content.length ||
        startPosition > endPosition) {
      return 0;
    }
    
    return endPosition - startPosition;
  }

  /// 根据配置重新计算页面分布
  static List<String> recalculatePages({
    required List<String> originalPages,
    required ReaderConfig newConfig,
    required Size screenSize,
  }) {
    // 合并所有页面内容
    final fullContent = originalPages.join('');
    
    // 使用新配置重新分页
    return calculatePages(
      content: fullContent,
      config: newConfig,
      screenSize: screenSize,
    );
  }
}
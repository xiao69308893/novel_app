import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/reader/reader_bloc.dart';
import '../pages/reader_page.dart';

/// 阅读器页面包装器，用于提供BLoC
class ReaderPageWrapper extends StatelessWidget {
  final String novelId;
  final String? chapterId;
  final int? chapterNumber;

  const ReaderPageWrapper({
    Key? key,
    required this.novelId,
    this.chapterId,
    this.chapterNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<ReaderBloc>(),
      child: ReaderPage(
        novelId: novelId,
        chapterId: chapterId,
        chapterNumber: chapterNumber,
      ),
    );
  }
}
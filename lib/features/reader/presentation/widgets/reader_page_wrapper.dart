import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/reader/reader_bloc.dart';
import '../pages/reader_page.dart';

/// 阅读器页面包装器，用于提供BLoC
class ReaderPageWrapper extends StatelessWidget {

  const ReaderPageWrapper({
    required this.novelId, super.key,
    this.chapterId,
    this.chapterNumber,
  });
  final String novelId;
  final String? chapterId;
  final int? chapterNumber;

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (BuildContext context) => GetIt.instance<ReaderBloc>(),
      child: ReaderPage(
        novelId: novelId,
        chapterId: chapterId,
        chapterNumber: chapterNumber,
      ),
    );
}
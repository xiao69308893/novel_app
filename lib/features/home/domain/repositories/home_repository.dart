// 首页仓储接口
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../shared/models/novel_model.dart';
import '../entities/banner.dart';
import '../entities/recommendation.dart';
import '../entities/ranking.dart';
import '../entities/home_config.dart';

abstract class HomeRepository {
  /// 获取首页配置
  Future<Either<AppError, HomeConfig>> getHomeConfig();

  /// 获取轮播图列表
  Future<Either<AppError, List<Banner>>> getBanners();

  /// 获取推荐内容
  Future<Either<AppError, List<Recommendation>>> getRecommendations({
    RecommendationType? type,
    int page = 1,
    int limit = 10,
  });

  /// 获取排行榜
  Future<Either<AppError, Ranking>> getRanking({
    required RankingType type,
    RankingPeriod period = RankingPeriod.weekly,
    int limit = 50,
  });

  /// 获取热门小说
  Future<Either<AppError, List<NovelSimpleModel>>> getHotNovels({
    int page = 1,
    int limit = 20,
  });

  /// 获取新书推荐
  Future<Either<AppError, List<NovelSimpleModel>>> getNewNovels({
    int page = 1,
    int limit = 20,
  });

  /// 获取编辑推荐
  Future<Either<AppError, List<NovelSimpleModel>>> getEditorRecommendations({
    int page = 1,
    int limit = 20,
  });

  /// 获取个性化推荐（需要登录）
  Future<Either<AppError, List<NovelSimpleModel>>> getPersonalizedRecommendations({
    int page = 1,
    int limit = 20,
  });

  /// 获取分类热门
  Future<Either<AppError, List<NovelSimpleModel>>> getCategoryHotNovels({
    required String categoryId,
    int page = 1,
    int limit = 20,
  });

  /// 搜索小说
  Future<Either<AppError, List<NovelSimpleModel>>> searchNovels({
    required String keyword,
    String? categoryId,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  });

  /// 获取搜索热词
  Future<Either<AppError, List<String>>> getHotSearchKeywords();

  /// 获取搜索建议
  Future<Either<AppError, List<String>>> getSearchSuggestions(String keyword);

  /// 记录搜索历史
  Future<Either<AppError, bool>> recordSearchHistory(String keyword);

  /// 获取搜索历史
  Future<Either<AppError, List<String>>> getSearchHistory();

  /// 清除搜索历史
  Future<Either<AppError, bool>> clearSearchHistory();
}
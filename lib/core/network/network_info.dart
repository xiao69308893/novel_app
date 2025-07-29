import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络连接信息接口
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// 网络连接信息实现
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      // 如果检查连接状态失败，默认认为有网络连接
      return true;
    }
  }
}
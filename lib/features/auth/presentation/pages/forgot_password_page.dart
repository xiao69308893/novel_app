// 忘记密码页面
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../cubit/verification_cubit.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/verification_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 手机找回
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneCodeController = TextEditingController();
  final _phonePasswordController = TextEditingController();
  
  // 邮箱找回
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _phoneCodeController.dispose();
    _phonePasswordController.dispose();
    _emailController.dispose();
    _emailCodeController.dispose();
    _emailPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CommonAppBar(
        title: '忘记密码',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            // 说明文本
            Text(
              '请选择找回密码的方式',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // 找回方式切换
            _buildTabBar(theme),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // 找回表单
            _buildResetForm(),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // 重置按钮
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color,
        tabs: const [
          Tab(text: '手机找回'),
          Tab(text: '邮箱找回'),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPhoneResetForm(),
          _buildEmailResetForm(),
        ],
      ),
    );
  }

  Widget _buildPhoneResetForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          AuthInputField(
            controller: _phoneController,
            labelText: '手机号',
            hintText: '请输入手机号',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入手机号';
              }
              if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                return '请输入正确的手机号';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          VerificationInput(
            controller: _phoneCodeController,
            phone: _phoneController.text,
            type: 'forgot_password',
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          AuthInputField(
            controller: _phonePasswordController,
            labelText: '新密码',
            hintText: '请输入新密码',
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入新密码';
              }
              if (value.length < 6) {
                return '密码至少6个字符';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailResetForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          AuthInputField(
            controller: _emailController,
            labelText: '邮箱',
            hintText: '请输入邮箱',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '请输入正确的邮箱格式';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          AuthInputField(
            controller: _emailCodeController,
            labelText: '验证码',
            hintText: '请输入6位验证码',
            prefixIcon: Icons.sms,
            keyboardType: TextInputType.number,
            maxLength: 6,
            suffixIcon: BlocBuilder<VerificationCubit, VerificationState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is! VerificationSent ? () => _sendEmailCode() : null,
                  child: Text(
                    state is VerificationSent ? '${state.countdown}s' : '获取验证码',
                  ),
                );
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入验证码';
              }
              if (value.length != 6) {
                return '请输入6位验证码';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          AuthInputField(
            controller: _emailPasswordController,
            labelText: '新密码',
            hintText: '请输入新密码',
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入新密码';
              }
              if (value.length < 6) {
                return '密码至少6个字符';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return AuthButton(
      text: '重置密码',
      onPressed: _handleResetPassword,
    );
  }

  void _sendEmailCode() {
    if (_emailController.text.isEmpty) {
      DialogUtils.showError(context, content: '请先输入邮箱');
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      DialogUtils.showError(context, content: '请输入正确的邮箱格式');
      return;
    }

    context.read<VerificationCubit>().sendEmailCode(
      email: _emailController.text.trim(),
      type: 'forgot_password',
    );
  }

  void _handleResetPassword() {
    final isPhoneReset = _tabController.index == 0;
    final formKey = isPhoneReset ? _phoneFormKey : _emailFormKey;
    
    if (formKey.currentState!.validate()) {
      // TODO: 实现忘记密码逻辑
      DialogUtils.showSuccess(
        context,
        content: '密码重置成功！',
      ).then((_) {
        Navigator.pop(context);
      });
    }
  }
}

// ========================================
// lib/core/errors/app_error.dart
// 应用错误类
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

enum AppErrorType {
  network,
  server,
  timeout,
  noInternet,
  unauthorized,
  forbidden,
  notFound,
  validation,
  unknown,
}

class AppError extends Equatable implements Exception {
  final String message;
  final AppErrorType type;
  final String? code;
  final dynamic data;

  const AppError({
    required this.message,
    required this.type,
    this.code,
    this.data,
  });

  // 工厂构造函数
  factory AppError.network(String message) {
    return AppError(
      message: message,
      type: AppErrorType.network,
    );
  }

  factory AppError.server(String message, {String? code}) {
    return AppError(
      message: message,
      type: AppErrorType.server,
      code: code,
    );
  }

  factory AppError.timeout() {
    return const AppError(
      message: '请求超时，请检查网络连接',
      type: AppErrorType.timeout,
    );
  }

  factory AppError.noInternet() {
    return const AppError(
      message: '无网络连接，请检查网络设置',
      type: AppErrorType.noInternet,
    );
  }

  factory AppError.unauthorized(String message) {
    return AppError(
      message: message,
      type: AppErrorType.unauthorized,
    );
  }

  factory AppError.forbidden(String message) {
    return AppError(
      message: message,
      type: AppErrorType.forbidden,
    );
  }

  factory AppError.notFound(String message) {
    return AppError(
      message: message,
      type: AppErrorType.notFound,
    );
  }

  factory AppError.validation(String message) {
    return AppError(
      message: message,
      type: AppErrorType.validation,
    );
  }

  factory AppError.unknown(String message) {
    return AppError(
      message: message,
      type: AppErrorType.unknown,
    );
  }

  // 从Dio异常创建
  factory AppError.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.timeout();
      
      case DioExceptionType.connectionError:
        return AppError.noInternet();
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final data = exception.response?.data;
        
        String message = '请求失败';
        if (data is Map<String, dynamic> && data['message'] != null) {
          message = data['message'].toString();
        }
        
        switch (statusCode) {
          case 400:
            return AppError.validation(message);
          case 401:
            return AppError.unauthorized(message);
          case 403:
            return AppError.forbidden(message);
          case 404:
            return AppError.notFound(message);
          case 500:
          case 502:
          case 503:
            return AppError.server(message, code: statusCode.toString());
          default:
            return AppError.network(message);
        }
      
      default:
        return AppError.unknown(exception.message ?? '未知错误');
    }
  }

  /// 是否可重试
  bool get isRetriable {
    switch (type) {
      case AppErrorType.network:
      case AppErrorType.timeout:
      case AppErrorType.noInternet:
      case AppErrorType.server:
        return true;
      case AppErrorType.unauthorized:
      case AppErrorType.forbidden:
      case AppErrorType.notFound:
      case AppErrorType.validation:
      case AppErrorType.unknown:
        return false;
    }
  }

  @override
  List<Object?> get props => [message, type, code, data];

  @override
  String toString() => 'AppError{message: $message, type: $type, code: $code}';
}
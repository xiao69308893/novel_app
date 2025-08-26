// 登录页面
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/verification_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 密码登录表单
  final _passwordFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 验证码登录表单
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CommonAppBar(
        title: '登录',
        showBackButton: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            DialogUtils.showError(
              context,
              content: state.message,
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AuthLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  children: [
                    // Logo区域
                    _buildLogo(),
                    
                    const SizedBox(height: AppTheme.spacingXLarge),
                    
                    // 登录方式切换
                    _buildTabBar(theme),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    // 登录表单
                    _buildLoginForm(),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    // 记住我和忘记密码
                    _buildOptions(),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    // 登录按钮
                    _buildLoginButton(),
                    
                    const SizedBox(height: AppTheme.spacingXLarge),
                    
                    // 注册链接
                    _buildRegisterLink(theme),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    // 临时跳过登录按钮（用于测试）
                    _buildSkipLoginButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.book,
        size: 60,
        color: Colors.white,
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
          Tab(text: '密码登录'),
          Tab(text: '验证码登录'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SizedBox(
      height: 200,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPasswordForm(),
          _buildPhoneForm(),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          AuthInputField(
            controller: _usernameController,
            labelText: '用户名',
            hintText: '请输入用户名/手机号/邮箱',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          AuthInputField(
            controller: _passwordController,
            labelText: '密码',
            hintText: '请输入密码',
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
                return '请输入密码';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
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
            controller: _codeController,
            phone: _phoneController.text,
            type: 'login',
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 记住我
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            const Text('记住我'),
          ],
        ),
        
        // 忘记密码
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/auth/forgot_password');
          },
          child: const Text('忘记密码？'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AuthButton(
      text: '登录',
      onPressed: _handleLogin,
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/auth/register');
          },
          child: const Text('立即注册'),
        ),
      ],
    );
  }

  Widget _buildSkipLoginButton() {
    return TextButton(
      onPressed: () {
        // 临时跳过登录，直接进入主页
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      },
      child: Text(
        '跳过登录（测试用）',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_tabController.index == 0) {
      // 密码登录
      if (_passwordFormKey.currentState!.validate()) {
        context.read<AuthCubit>().login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } else {
      // 验证码登录
      if (_phoneFormKey.currentState!.validate()) {
        if (_codeController.text.length != 6) {
          DialogUtils.showError(context, content: '请输入6位验证码');
          return;
        }
        
        // TODO: 实现验证码登录
        DialogUtils.showInfo(context, content: '验证码登录功能开发中');
      }
    }
  }
}

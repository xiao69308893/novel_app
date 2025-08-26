// 注册页面
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const CommonAppBar(
        title: '注册',
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthError) {
            DialogUtils.showError(
              context,
              content: state.message,
            );
          } else if (state is AuthAuthenticated) {
            DialogUtils.showSuccess(
              context,
              content: '注册成功！',
            ).then((_) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (Route route) => false,
              );
            });
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) => LoadingOverlay(
              isLoading: state is AuthLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 用户名
                      AuthInputField(
                        controller: _usernameController,
                        labelText: '用户名',
                        hintText: '请输入用户名',
                        prefixIcon: Icons.person,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          if (value.length < 3) {
                            return '用户名至少3个字符';
                          }
                          if (value.length > 20) {
                            return '用户名不能超过20个字符';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingRegular),

                      // 密码
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
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          if (value.length < 6) {
                            return '密码至少6个字符';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingRegular),

                      // 确认密码
                      AuthInputField(
                        controller: _confirmPasswordController,
                        labelText: '确认密码',
                        hintText: '请再次输入密码',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return '请确认密码';
                          }
                          if (value != _passwordController.text) {
                            return '两次输入的密码不一致';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingRegular),

                      // 手机号（可选）
                      AuthInputField(
                        controller: _phoneController,
                        labelText: '手机号（可选）',
                        hintText: '请输入手机号',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (String? value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                              return '请输入正确的手机号';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingRegular),

                      // 邮箱（可选）
                      AuthInputField(
                        controller: _emailController,
                        labelText: '邮箱（可选）',
                        hintText: '请输入邮箱',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return '请输入正确的邮箱格式';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingRegular),

                      // 邀请码（可选）
                      AuthInputField(
                        controller: _inviteCodeController,
                        labelText: '邀请码（可选）',
                        hintText: '请输入邀请码',
                        prefixIcon: Icons.card_giftcard,
                      ),

                      const SizedBox(height: AppTheme.spacingLarge),

                      // 服务条款
                      _buildTermsCheckbox(),

                      const SizedBox(height: AppTheme.spacingLarge),

                      // 注册按钮
                      AuthButton(
                        text: '注册',
                        onPressed: _agreeTerms ? _handleRegister : null,
                      ),

                      const SizedBox(height: AppTheme.spacingLarge),

                      // 登录链接
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );

  Widget _buildTermsCheckbox() {
    final ThemeData theme = Theme.of(context);
    
    return Row(
      children: <Widget>[
        Checkbox(
          value: _agreeTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreeTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: Wrap(
            children: <Widget>[
              Text('我已阅读并同意', style: theme.textTheme.bodyMedium),
              GestureDetector(
                onTap: () {
                  // 打开用户协议
                  DialogUtils.showInfo(context, content: '用户协议页面');
                },
                child: Text(
                  '《用户协议》',
                  style: TextStyle(
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text('和', style: theme.textTheme.bodyMedium),
              GestureDetector(
                onTap: () {
                  // 打开隐私政策
                  DialogUtils.showInfo(context, content: '隐私政策页面');
                },
                child: Text(
                  '《隐私政策》',
                  style: TextStyle(
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    final ThemeData theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '已有账号？',
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('立即登录'),
        ),
      ],
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        _emailController.text.trim().isEmpty 
            ? '${_usernameController.text.trim()}@example.com'
            : _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );
    }
  }
}

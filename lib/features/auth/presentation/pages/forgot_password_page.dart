// 忘记密码页面
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../cubit/verification_cubit.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/verification_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 手机找回
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phoneCodeController = TextEditingController();
  final TextEditingController _phonePasswordController = TextEditingController();
  
  // 邮箱找回
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  final TextEditingController _emailPasswordController = TextEditingController();
  
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
    final ThemeData theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CommonAppBar(
        title: '忘记密码',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: <Widget>[
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

  Widget _buildTabBar(ThemeData theme) => DecoratedBox(
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
        tabs: const <Widget>[
          Tab(text: '手机找回'),
          Tab(text: '邮箱找回'),
        ],
      ),
    );

  Widget _buildResetForm() => SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildPhoneResetForm(),
          _buildEmailResetForm(),
        ],
      ),
    );

  Widget _buildPhoneResetForm() => Form(
      key: _phoneFormKey,
      child: Column(
        children: <Widget>[
          AuthInputField(
            controller: _phoneController,
            labelText: '手机号',
            hintText: '请输入手机号',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (String? value) {
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
            validator: (String? value) {
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

  Widget _buildEmailResetForm() => Form(
      key: _emailFormKey,
      child: Column(
        children: <Widget>[
          AuthInputField(
            controller: _emailController,
            labelText: '邮箱',
            hintText: '请输入邮箱',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (String? value) {
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
              builder: (BuildContext context, VerificationState state) => TextButton(
                  onPressed: state is! VerificationSent ? _sendEmailCode : null,
                  child: Text(
                    state is VerificationSent ? '${state.countdown}s' : '获取验证码',
                  ),
                ),
            ),
            validator: (String? value) {
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
            validator: (String? value) {
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

  Widget _buildResetButton() => AuthButton(
      text: '重置密码',
      onPressed: _handleResetPassword,
    );

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
    final bool isPhoneReset = _tabController.index == 0;
    final GlobalKey<FormState> formKey = isPhoneReset ? _phoneFormKey : _emailFormKey;
    
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
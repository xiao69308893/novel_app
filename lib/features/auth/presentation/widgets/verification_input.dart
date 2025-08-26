// 验证码输入组件
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../cubit/verification_cubit.dart';
import 'auth_input_field.dart';

class VerificationInput extends StatelessWidget {

  const VerificationInput({
    required this.controller, required this.phone, required this.type, super.key,
  });
  final TextEditingController controller;
  final String phone;
  final String type;

  @override
  Widget build(BuildContext context) => Row(
      children: <Widget>[
        Expanded(
          child: AuthInputField(
            controller: controller,
            labelText: '验证码',
            hintText: '请输入6位验证码',
            prefixIcon: Icons.sms,
            keyboardType: TextInputType.number,
            maxLength: 6,
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
        ),
        
        const SizedBox(width: AppTheme.spacingRegular),
        
        BlocBuilder<VerificationCubit, VerificationState>(
          builder: (BuildContext context, VerificationState state) => SizedBox(
              width: 100,
              height: 48,
              child: ElevatedButton(
                onPressed: _canSendCode(state) ? () => _sendCode(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                  ),
                ),
                child: _buildButtonChild(state),
              ),
            ),
        ),
      ],
    );

  bool _canSendCode(VerificationState state) => state is! VerificationSending && state is! VerificationSent;

  Widget _buildButtonChild(VerificationState state) {
    if (state is VerificationSending) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (state is VerificationSent) {
      return Text('${state.countdown}s');
    } else {
      return const Text('获取验证码');
    }
  }

  void _sendCode(BuildContext context) {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入手机号')),
      );
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的手机号')),
      );
      return;
    }

    context.read<VerificationCubit>().sendSmsCode(
      phone: phone,
      type: type,
    );
  }
}
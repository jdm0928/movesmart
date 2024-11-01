import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> forgotPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      _showError(context, '이메일을 입력하세요.');
      return;
    }

    try {
      // 비밀번호 재설정 이메일 발송
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccess(context, '비밀번호 재설정 이메일이 발송되었습니다.');
    } catch (e) {
      _showError(context, '오류 발생: $e');
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

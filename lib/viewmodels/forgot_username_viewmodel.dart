import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotUsernameViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> forgotUsername(BuildContext context, String email) async {
    if (email.isEmpty) {
      _showError(context, '이메일을 입력하세요.');
      return;
    }

    try {
      // 이메일로 사용자 찾기
      var user = (await _auth.fetchSignInMethodsForEmail(email)).isNotEmpty;

      if (user) {
        _showSuccess(context, '이메일로 아이디가 발송되었습니다.');
      } else {
        _showError(context, '해당 이메일로 등록된 아이디가 없습니다.');
      }
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

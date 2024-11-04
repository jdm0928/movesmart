import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movesmart/views/forgot_password_screen.dart';
import 'package:movesmart/views/forgot_username_screen.dart';
import '../services/navigation_service.dart';
import '../views/home_screen.dart';
import '../views/signup_screen.dart'; // SignUpScreen 임포트 추가

class LoginViewModel extends ChangeNotifier {
  final NavigationService _navigationService = NavigationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 로그인 함수
  Future<void> login(BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError(context, '아이디와 비밀번호를 입력하세요.');
      return;
    }

    try {
      // Firebase Authentication을 사용하여 로그인
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      // 로그인 성공 시 사용자 정보를 확인
      if (userCredential.user != null) {
        // 홈 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showError(context, '로그인 실패');
      }
    } on FirebaseAuthException catch (e) {
      // 로그인 실패 시 에러 메시지 표시
      if (e.code == 'user-not-found') {
        _showError(context, '해당 아이디가 존재하지 않습니다.');
      } else if (e.code == 'wrong-password') {
        _showError(context, '비밀번호가 잘못되었습니다.');
      } else {
        _showError(context, '로그인 실패');
      }
    } catch (error) {
      // 다른 에러 처리
      _showError(context, '로그인 중 오류가 발생했습니다: $error');
    }
  }

  // 회원가입 화면으로 이동하는 함수
  void navigateToSignUp(BuildContext context) {
    _navigationService.navigateTo(context, SignUpScreen());
  }

  // 아이디 찾기 화면으로 이동하는 함수
  void navigateToForgotUsername(BuildContext context) {
    _navigationService.navigateTo(context, ForgotUsernameScreen());
  }

  // 아이디 찾기 화면으로 이동하는 함수
  void navigateToForgotPassword(BuildContext context) {
    _navigationService.navigateTo(context, ForgotPasswordScreen());
  }

  // 에러 메시지 표시 함수
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }
}

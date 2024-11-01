import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트 추가
import 'package:movesmart/views/login_screen.dart';
import '../services/navigation_service.dart';

class SignUpViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스 생성
  final NavigationService _navigationService = NavigationService(); // NavigationService 인스턴스 생성

  // 회원가입 함수
  Future<void> signUp(BuildContext context, String username, String email, String password, String phone) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showError(context, '모든 필드를 입력하세요.');
      return;
    }

    try {
      // Firebase Authentication을 사용하여 회원가입
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 회원가입 성공 시 Firestore에 추가 정보 저장
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'phone': phone,
          'createdAt': Timestamp.now(),
        });

        // 성공 알림 표시
        _showSuccess(context, '회원가입이 완료되었습니다!');

        // 로그인 화면으로 이동
        _navigationService.navigateTo(context, LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      // 회원가입 실패 시 에러 메시지 표시
      if (e.code == 'email-already-in-use') {
        _showError(context, '이 이메일은 이미 사용 중입니다.');
      } else if (e.code == 'weak-password') {
        _showError(context, '비밀번호는 6자 이상이어야 합니다.');
      } else {
        _showError(context, '회원가입 실패: ${e.message}');
      }
    }
  }

  // 성공 메시지 표시 함수
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // 성공 메시지 색상
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }

  // 에러 메시지 표시 함수
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // 에러 메시지 색상
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }
}

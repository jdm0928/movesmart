import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 임포트
import '../views/login_screen.dart'; // 로그인 화면 임포트

class ProfileSettingsViewModel {
  // 로그아웃 기능
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Firebase에서 로그아웃
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
    );
  }
}

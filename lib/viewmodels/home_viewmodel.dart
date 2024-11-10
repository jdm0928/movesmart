import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 임포트
import '../views/login_screen.dart'; // 로그인 화면 임포트
import '../views/pathfinding_screen.dart'; // 길찾기 화면 임포트
import '../views/navigation_screen.dart'; // 주행 내비 화면 임포트
import '../views/translation_screen.dart'; // 번역기 화면 임포트
import '../views/weather_screen.dart'; // 날씨 예보 화면 임포트

class HomeViewModel {
  // 로그아웃 기능
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Firebase에서 로그아웃
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
    );
  }

  // 길찾기 화면으로 이동
  void navigateToPathfinding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PathfindingScreen()), // 길찾기 화면으로 이동
    );
  }

  // 주행 내비 화면으로 이동
  void navigateToNavigation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NavigationScreen()), // 주행 내비 화면으로 이동
    );
  }

  // 번역기 화면으로 이동
  void navigateToTranslation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TranslationScreen()), // 번역기 화면으로 이동
    );
  }

  // 날씨 예보 화면으로 이동
  void navigateToWeather(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WeatherScreen()), // 날씨 예보 화면으로 이동
    );
  }
}

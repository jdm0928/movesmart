import 'dart:async';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../views/login_screen.dart'; // 로그인 화면 임포트

class SplashViewModel extends ChangeNotifier {
  final NavigationService _navigationService = NavigationService();

  void navigateToLogin(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      _navigationService.navigateTo(context, LoginScreen());
    });
  }
}

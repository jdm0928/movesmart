import 'package:flutter/material.dart';
import '../viewmodels/splash_viewmodel.dart';
import '../views/login_screen.dart'; // 로그인 화면 임포트

class SplashScreen extends StatelessWidget {
  final SplashViewModel viewModel = SplashViewModel();

  @override
  Widget build(BuildContext context) {
    viewModel.navigateToLogin(context); // 로그인 화면으로 이동

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Movesmart!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import '../viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SplashViewModel을 Provider에서 가져옴
    final viewModel = Provider.of<SplashViewModel>(context, listen: false);

    // 화면이 빌드된 후 로그인 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.navigateToLogin(context); // 로그인 화면으로 이동
    });

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

import 'package:flutter/material.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../views/login_screen.dart'; // LoginScreen 임포트 추가

class SignUpScreen extends StatelessWidget {
  final SignUpViewModel viewModel = SignUpViewModel();
  final TextEditingController usernameController = TextEditingController(); // 아이디 입력
  final TextEditingController emailController = TextEditingController(); // 이메일 입력
  final TextEditingController passwordController = TextEditingController(); // 비밀번호 입력
  final TextEditingController phoneController = TextEditingController(); // 전화번호 입력

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 뒤로 가기 아이콘
          onPressed: () {
            // LoginScreen으로 이동
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String username = usernameController.text;
                  String email = emailController.text;
                  String password = passwordController.text;
                  String phone = phoneController.text;
                  viewModel.signUp(context, username, email, password, phone); // 수정된 부분
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../viewmodels/forgot_username_viewmodel.dart';

class ForgotUsernameScreen extends StatelessWidget {
  final ForgotUsernameViewModel viewModel = ForgotUsernameViewModel();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디 찾기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String email = emailController.text;
                  viewModel.forgotUsername(context, email);
                },
                child: const Text('아이디 찾기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

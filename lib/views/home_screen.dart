import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 임포트
import '../views/login_screen.dart'; // 로그인 화면 임포트

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // 로그아웃 아이콘
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Firebase에서 로그아웃
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
              );
            },
          ),
        ],
      ),
      body: Center(
        child: const Text(
          'This is the Home Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../viewmodels/profile_setting_viewmodel.dart'; // ViewModel 임포트

class ProfileSettingsScreen extends StatelessWidget {
  final ProfileSettingsViewModel _viewModel = ProfileSettingsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('YOUR_IMAGE_URL'), // 사용자 이미지 URL
              backgroundColor: Colors.grey, // 이미지 로드 실패 시 기본 색
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 소셜 아이디 연동 로직 추가
              },
              child: const Text('소셜 아이디 연동'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _viewModel.logout(context); // 로그아웃 호출
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

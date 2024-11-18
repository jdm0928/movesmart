import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _localPartController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final List<String> _domainList = ['gmail.com', 'naver.com', 'daum.net', '직접 입력'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('비밀번호 찾기'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen()), // 로그인 화면으로 이동
                  );
                }
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEmailField(viewModel),
                  SizedBox(height: 20),
                  // 인증 메시지 표시
                  if (viewModel.verificationMessage.message.isNotEmpty) ...[
                    Text(
                      viewModel.verificationMessage.message,
                      style: TextStyle(color: viewModel.verificationMessage.color),
                    ),
                  ],
                  SizedBox(height: 20),
                  // 이메일 존재 여부 확인 버튼
                  ElevatedButton(
                    onPressed: (viewModel.isEmailValid) ? () {
                      viewModel.checkEmailExists(); // 이메일 존재 여부 확인
                    } : null,
                    child: Text('이메일 존재 여부 확인'),
                  ),
                  SizedBox(height: 20),
                  // 비밀번호 재설정 버튼
                  ElevatedButton(
                    onPressed: (viewModel.isEmailExists) ? () {
                      viewModel.sendPasswordResetEmail(); // 비밀번호 재설정 링크 발송
                    } : null,
                    child: Text('비밀번호 재설정하기'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField(ForgotPasswordViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _localPartController,
                onChanged: (value) {
                  viewModel.onEmailChanged(value, _domainController.text); // 이메일 변경 처리
                },
                decoration: InputDecoration(
                  labelText: '로컬 부분',
                  border: OutlineInputBorder(),
                  suffixIcon: _localPartController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _localPartController.clear();
                      viewModel.onEmailChanged('', _domainController.text);
                    },
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('@'),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _domainController,
                onChanged: (value) {
                  viewModel.onEmailChanged(_localPartController.text, value); // 이메일 변경 처리
                },
                decoration: InputDecoration(
                  labelText: '도메인',
                  border: OutlineInputBorder(),
                  suffixIcon: _domainController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _domainController.clear();
                      viewModel.onEmailChanged(_localPartController.text, '');
                    },
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(width: 16),
            DropdownButton<String>(
              value: _domainController.text.isNotEmpty &&
                  _domainList.contains(_domainController.text)
                  ? _domainController.text
                  : null,
              hint: Text('도메인 선택'),
              items: _domainList.map((String domain) {
                return DropdownMenuItem<String>(
                  value: domain,
                  child: Text(domain),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  if (newValue == '직접 입력') {
                    _domainController.clear();
                  } else {
                    _domainController.text = newValue;
                  }
                  viewModel.onEmailChanged(_localPartController.text, _domainController.text); // 이메일 변경 처리
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

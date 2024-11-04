import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import '../viewmodels/login_viewmodel.dart'; // LoginViewModel import

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        resizeToAvoidBottomInset: false, // 키패드가 나타날 때 요소들이 올라가지 않도록 설정
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이디 입력창
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // 비밀번호 입력창
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // 로그인 버튼
                ElevatedButton(
                  onPressed: () {
                    String username = usernameController.text;
                    String password = passwordController.text;
                    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
                    viewModel.login(context, username, password);
                  },
                  child: const Text('로그인 하기'),
                ),
                const SizedBox(height: 18),

                // 회원가입, 아이디 찾기, 비밀번호 찾기 버튼 (가로 방향)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        final viewModel = Provider.of<LoginViewModel>(context, listen: false);
                        viewModel.navigateToSignUp(context);
                      },
                      child: const Text('회원가입'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        final viewModel = Provider.of<LoginViewModel>(context, listen: false);
                        viewModel.navigateToForgotUsername(context);
                      },
                      child: const Text('아이디 찾기'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        final viewModel = Provider.of<LoginViewModel>(context, listen: false);
                        viewModel.navigateToForgotPassword(context);
                      },
                      child: const Text('비밀번호 찾기'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 소셜 로그인 구분선 텍스트
                Text(
                  '------------------------------- 또는 -------------------------------',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),

                // 소셜 로그인 버튼 (세로 방향)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 카카오 로그인 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 카카오 로그인 로직 호출
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0), // 패딩을 0으로 설정
                        backgroundColor: Colors.transparent, // 배경 투명
                      ),
                      child: Container(
                        width: 260, // 원하는 너비
                        height: 50, // 원하는 높이
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // 테두리 추가
                        ),
                        child: Image.asset('assets/kakao_login_large_narrow.png', fit: BoxFit.fill), // 카카오 로고 이미지
                      ),
                    ),
                    const SizedBox(height: 16), // 버튼 간격
                    // 구글 로그인 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 구글 로그인 로직 호출
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0), // 패딩을 0으로 설정
                        backgroundColor: Colors.transparent, // 배경 투명
                      ),
                      child: Container(
                        width: 260, // 원하는 너비
                        height: 50, // 원하는 높이
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // 테두리 추가
                        ),
                        child: Image.asset('assets/android_light_sq_SI@4x.png', fit: BoxFit.fill), // 구글 로고 이미지
                      ),
                    ),
                    const SizedBox(height: 16), // 버튼 간격
                    // 네이버 로그인 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 네이버 로그인 로직 호출
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0), // 패딩을 0으로 설정
                        backgroundColor: Colors.transparent, // 배경 투명
                      ),
                      child: Container(
                        width: 260, // 원하는 너비
                        height: 50, // 원하는 높이
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // 테두리 추가
                        ),
                        child: Image.asset('assets/btnG_완성형.png', fit: BoxFit.fill), // 네이버 로고 이미지
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
        ],
      ),
    ).then((value) => value ??
        // 기본값 반환
        false);
  }
}

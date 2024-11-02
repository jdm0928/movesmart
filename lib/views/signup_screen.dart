import 'package:flutter/material.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../views/login_screen.dart'; // LoginScreen 임포트 추가
import '../models/country_codes.dart'; // 국가 코드 파일 임포트

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpViewModel viewModel = SignUpViewModel();
  final TextEditingController nicknameController = TextEditingController(); // 닉네임 입력
  final TextEditingController usernameController = TextEditingController(); // 아이디 입력
  final TextEditingController emailController = TextEditingController(); // 이메일 입력
  final TextEditingController passwordController = TextEditingController(); // 비밀번호 입력
  final TextEditingController confirmPasswordController = TextEditingController(); // 비밀번호 확인 입력
  final TextEditingController phoneController = TextEditingController(); // 전화번호 입력
  final TextEditingController verificationCodeController = TextEditingController(); // 인증 코드 입력

  String selectedCountryCode = '+82'; // 기본 국가 번호 설정
  bool passwordsMatch = true; // 비밀번호 확인 상태
  String usernameCheckMessage = ''; // 아이디 중복 확인 메시지
  Color usernameCheckColor = Colors.transparent; // 아이디 중복 확인 메시지 색상

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
              // 닉네임 입력 필드
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 이메일 입력 필드
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 아이디 입력 필드 및 중복 확인 버튼
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: '아이디',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // 중복 확인 로직 호출
                      bool isAvailable = await viewModel.checkUsername(context, usernameController.text);
                      setState(() {
                        if (isAvailable) {
                          usernameCheckMessage = '사용 가능한 아이디입니다.';
                          usernameCheckColor = Colors.green;
                        } else {
                          usernameCheckMessage = '이미 사용 중인 아이디입니다.';
                          usernameCheckColor = Colors.red;
                        }
                      });
                    },
                    child: const Text('중복 확인'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 아이디 중복 확인 메시지
              Text(
                usernameCheckMessage,
                style: TextStyle(color: usernameCheckColor, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력 필드
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: UnderlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인 입력 필드
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: UnderlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    passwordsMatch = passwordController.text == value; // 비밀번호 확인
                  });
                },
              ),
              if (!passwordsMatch)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '비밀번호가 다릅니다.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // 전화번호 입력 필드
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCountryCode,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCountryCode = newValue!; // 선택한 국가 번호 저장
                        });
                      },
                      items: countryCodes.map<DropdownMenuItem<String>>((CountryCode value) {
                        return DropdownMenuItem<String>(
                          value: value.code,
                          child: Text('${value.country} (${value.code})'), // 국가 이름과 번호 표시
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: '전화번호',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // 전화번호 인증 로직 호출
                      viewModel.sendVerificationCode(context, phoneController.text, selectedCountryCode); // 선택한 국가 번호 사용
                    },
                    child: const Text('인증하기'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SMS 코드 입력 필드
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: verificationCodeController,
                      decoration: InputDecoration(
                        labelText: '인증 코드',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // 인증 코드 입력 로직
                    },
                    child: const Text('확인'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 타이머 표시
              if (viewModel.isTimerActive)
                Text('남은 시간: ${viewModel.remainingTime} 초'),
              const SizedBox(height: 20),

              // 회원가입 버튼
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    String nickname = nicknameController.text;
                    String username = usernameController.text;
                    String email = emailController.text;
                    String password = passwordController.text;
                    String phone = phoneController.text;
                    String verificationCode = verificationCodeController.text;
                    viewModel.signUp(context, nickname, username, email, password, phone, verificationCode); // 회원가입 호출
                  },
                  child: const Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

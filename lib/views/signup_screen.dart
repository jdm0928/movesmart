import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart'; // ViewModel import
import 'login_screen.dart'; // 로그인 화면 import

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _localPartController = TextEditingController(); // 로컬 부분 컨트롤러
  final TextEditingController _domainController = TextEditingController(); // 도메인 부분 컨트롤러
  final List<String> _domainList = ['gmail.com', 'naver.com', 'daum.net', 'nate.com', '직접 입력']; // 도메인 리스트

  @override
  void dispose() {
    _nicknameController.dispose();
    _localPartController.dispose(); // 로컬 부분 컨트롤러 메모리 해제
    _domainController.dispose(); // 도메인 부분 컨트롤러 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 ViewModel 가져오기
    final viewModel = Provider.of<SignUpViewModel>(context);

    // 닉네임 변경 시 TextEditingController에 반영
    _nicknameController.text = viewModel.nickname;
    _nicknameController.selection = TextSelection.fromPosition(TextPosition(offset: _nicknameController.text.length));

    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            bool? shouldExit = await viewModel.showExitConfirmationDialog(context);
            if (shouldExit == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 닉네임 입력 박스
              TextField(
                controller: _nicknameController,
                onChanged: (value) {
                  viewModel.onNicknameChanged(value); // 닉네임 입력 처리
                },
                decoration: InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                  suffixIcon: viewModel.nickname.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      viewModel.clearNickname(); // X 버튼 클릭 시 닉네임 초기화
                      _nicknameController.clear(); // 닉네임 입력 필드 비우기
                    },
                  )
                      : null,
                ),
              ),
              if (!viewModel.isNicknameValid) // 닉네임 유효성 검사 메시지
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    viewModel.nicknameErrorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 32),

              // 이메일 입력 박스
              Row(
                children: [
                  // 로컬 부분 입력
                  Expanded(
                    child: TextField(
                      controller: _localPartController,
                      onChanged: (value) {
                        viewModel.onEmailChanged(value + '@' + _domainController.text); // 변경된 로컬 부분을 업데이트
                      },
                      decoration: InputDecoration(
                        labelText: '로컬 부분',
                        border: OutlineInputBorder(),
                        suffixIcon: _localPartController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _localPartController.clear(); // 로컬 부분 입력 필드 비우기
                            viewModel.onEmailChanged(''); // 이메일 업데이트
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // 간격 추가
                  Text('@'), // 고정된 @ 기호
                  SizedBox(width: 8), // 간격 추가
                  // 도메인 부분 입력
                  Expanded(
                    child: TextField(
                      controller: _domainController,
                      onChanged: (value) {
                        viewModel.onEmailChanged(_localPartController.text + '@' + value); // 이메일 업데이트
                      },
                      decoration: InputDecoration(
                        labelText: '도메인',
                        border: OutlineInputBorder(),
                        suffixIcon: _domainController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _domainController.clear(); // 도메인 입력 필드 비우기
                            viewModel.onEmailChanged(''); // 이메일 업데이트
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // 간격 추가
                  // 도메인 선택 리스트
                  DropdownButton<String>(
                    value: _domainController.text.isEmpty ? null : _domainController.text,
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
                          _domainController.clear(); // 직접 입력 선택 시 도메인 필드 비우기
                        } else {
                          _domainController.text = newValue;
                        }
                        viewModel.onEmailChanged(_localPartController.text + '@' + _domainController.text); // 이메일 업데이트
                      }
                    },
                  ),
                ],
              ),
              if (!viewModel.isEmailValid) // 이메일 유효성 검사 메시지
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    viewModel.emailErrorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 8),

              // 발송 버튼
              ElevatedButton(
                onPressed: viewModel.isEmailValid && !viewModel.isEmailSent
                    ? () {
                  viewModel.sendVerificationEmail(); // 이메일 발송 함수 호출
                }
                    : null, // 유효하지 않거나 이미 발송된 경우 비활성화
                child: Text('발송'),
              ),
              SizedBox(height: 32),

              // 비밀번호 입력 박스
              TextField(
                onChanged: (value) {
                  viewModel.password = value; // 비밀번호 입력 처리
                },
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      viewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off, // 비밀번호 가시성 상태에 따라 아이콘 변경
                    ),
                    onPressed: () {
                      setState(() {
                        viewModel.isPasswordVisible = !viewModel.isPasswordVisible; // 비밀번호 가시성 상태 변경
                      });
                    },
                  ),
                ),
                obscureText: !viewModel.isPasswordVisible, // 비밀번호 가시성에 따라 숨김 처리
              ),
              SizedBox(height: 32),

              // 회원가입 버튼
              ElevatedButton(
                onPressed: () {
                  viewModel.signUp(); // 회원가입 처리
                },
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

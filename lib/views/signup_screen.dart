import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart'; // ViewModel import
import 'login_screen.dart'; // 로그인 화면 import
import '../models/terms_of_service.dart'; // 서비스 이용 약관 import
import '../models/privacy_policy.dart'; // 개인정보 처리 방침 import
import '../models/marketing_consent.dart'; // 마케팅 수신 동의 import

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _localPartController = TextEditingController(); // 로컬 부분 컨트롤러
  final TextEditingController _domainController = TextEditingController(); // 도메인 부분 컨트롤러
  final List<String> _domainList = ['직접 입력', 'gmail.com', 'naver.com', 'daum.net', 'nate.com']; // 도메인 리스트
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  final TextEditingController _confirmPasswordController = TextEditingController(); // 비밀번호 확인 입력 컨트롤러

  @override
  void dispose() {
    _nicknameController.dispose();
    _localPartController.dispose();
    _domainController.dispose();
    _passwordController.dispose(); // 비밀번호 입력 컨트롤러 메모리 해제
    _confirmPasswordController.dispose(); // 비밀번호 확인 컨트롤러 메모리 해제
    super.dispose();
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('서비스 이용 약관'),
          content: SingleChildScrollView(
            child: Text(termsOfService),
          ),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('개인정보 처리 방침'),
          content: SingleChildScrollView(
            child: Text(privacyPolicy),
          ),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMarketingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('마케팅 수신 동의'),
          content: SingleChildScrollView(
            child: Text(marketingConsent),
          ),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);

    // 닉네임 변경 시 TextEditingController에 반영
    _nicknameController.text = viewModel.nickname;
    _nicknameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nicknameController.text.length));

    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            bool? shouldExit =
                await viewModel.showExitConfirmationDialog(context);
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
                  setState(() {}); // 상태 업데이트
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
                      setState(() {}); // 상태 업데이트
                    },
                  )
                      : null,
                ),
              ),

              // 닉네임 에러 메시지 영역 제거
              if (viewModel.nickname.isNotEmpty && !viewModel.isNicknameValid) // 유효하지 않은 경우만 표시
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Text(
                    viewModel.nicknameErrorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 16),

              // 이메일 입력 박스
              Row(
                children: [
                  // 로컬 부분 입력
                  Expanded(
                    child: TextField(
                      controller: _localPartController,
                      onChanged: (value) {
                        viewModel.onEmailChanged(value, _domainController.text); // 변경된 로컬 부분을 업데이트
                        setState(() {}); // 상태 업데이트
                      },
                      decoration: InputDecoration(
                        labelText: '로컬 부분',
                        border: OutlineInputBorder(),
                        suffixIcon: _localPartController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _localPartController.clear(); // 로컬 부분 입력 필드 비우기
                            viewModel.onEmailChanged('', _domainController.text); // 이메일 업데이트
                            setState(() {}); // 상태 업데이트
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
                        viewModel.onEmailChanged(_localPartController.text, value); // 이메일 업데이트
                        setState(() {}); // 상태 업데이트
                      },
                      decoration: InputDecoration(
                        labelText: '도메인',
                        border: OutlineInputBorder(),
                        suffixIcon: _domainController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _domainController.clear(); // 도메인 입력 필드 비우기
                            viewModel.onEmailChanged(_localPartController.text, ''); // 이메일 업데이트
                            setState(() {}); // 상태 업데이트
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                  // 도메인 선택 리스트
                  DropdownButton<String>(
                    value: _domainController.text.isNotEmpty &&
                        _domainList.contains(_domainController.text)
                        ? _domainController.text
                        : null, // 도메인이 존재할 때만 value 설정
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
                          _domainController.text = newValue; // 선택한 도메인으로 설정
                        }
                        viewModel.onEmailChanged(_localPartController.text, _domainController.text); // 이메일 업데이트
                      }
                    },
                  ),
                ],
              ),

              // 이메일 발송 버튼과 유효성 검사 메시지를 분리하여 각각 왼쪽, 오른쪽에 배치
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 이메일 유효성 검사 메시지
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        // 메시지가 표시되는 조건을 수정
                        (!viewModel.isEmailValid &&
                            (_localPartController.text.isNotEmpty || _domainController.text.isNotEmpty))
                            ? viewModel.emailErrorMessage
                            : '', // 조건에 따라 메시지를 표시하거나 빈 문자열 반환
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  // 발송 버튼
                  ElevatedButton(
                    onPressed: viewModel.isEmailValid && !viewModel.isEmailSent
                        ? () {
                      viewModel.sendVerificationEmail(); // 이메일 발송 함수 호출
                    }
                        : null, // 유효하지 않거나 이미 발송된 경우 비활성화
                    child: Text(viewModel.isEmailSent ? '재발송' : '발송'),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // 비밀번호 입력 박스
              TextField(
                controller: _passwordController, // 비밀번호 입력을 위한 TextEditingController 추가
                onChanged: (value) {
                  viewModel.password = value; // 비밀번호 입력 처리
                  viewModel.checkPasswordComplexity(); // 비밀번호 복잡성 체크
                  viewModel.checkPasswordMatch(); // 비밀번호 확인 일치 여부 체크
                  setState(() {}); // 상태 업데이트
                },
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (viewModel.password.isNotEmpty) // 비밀번호가 있을 때만 X 버튼 표시
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            viewModel.clearPassword(); // 비밀번호 초기화 메서드 호출
                            _passwordController.clear(); // 비밀번호 입력 필드 비우기
                            viewModel.confirmPassword = ''; // 비밀번호 확인 초기화
                            _confirmPasswordController.clear(); // 비밀번호 확인 입력 필드 비우기
                            viewModel.checkPasswordMatch(); // 비밀번호 일치 여부 재확인
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          viewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off, // 비밀번호 가시성 상태에 따라 아이콘 변경
                        ),
                        onPressed: () {
                          setState(() {
                            viewModel.isPasswordVisible = !viewModel.isPasswordVisible; // 비밀번호 가시성 상태 변경
                          });
                        },
                      ),
                    ],
                  ),
                ),
                obscureText: !viewModel.isPasswordVisible, // 비밀번호 가시성에 따라 숨김 처리
              ),

              SizedBox(height: 8),

              // 비밀번호 안정성 표시
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          viewModel.passwordStrengthColor,
                          Colors.grey, // 배경색
                        ],
                        stops: [viewModel.passwordStrengthValue, viewModel.passwordStrengthValue],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(width: 8),
                  // 비밀번호 안정성 메시지 색상 변경
                  Text(
                    viewModel.passwordStrengthMessage,
                    style: TextStyle(
                      color: viewModel.passwordStrengthMessage.contains('미흡')
                          ? Colors.red
                          : viewModel.passwordStrengthMessage.contains('양호')
                          ? Colors.blue
                          : viewModel.passwordStrengthMessage.contains('강력')
                          ? Colors.green
                          : Colors.black, // 기본 색상
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 비밀번호 확인 입력 박스
              TextField(
                controller: _confirmPasswordController, // 비밀번호 확인을 위한 TextEditingController 추가
                onChanged: (value) {
                  viewModel.confirmPassword = value; // 비밀번호 확인 처리
                  viewModel.checkPasswordMatch(); // 비밀번호 일치 여부 체크
                },
                enabled: viewModel.password.length >= 8, // 비밀번호가 8자 이상일 때만 활성화
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (viewModel.confirmPassword.isNotEmpty) // 비밀번호 확인이 있을 때만 X 버튼 표시
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            viewModel.confirmPassword = ''; // 비밀번호 확인 초기화
                            _confirmPasswordController.clear(); // 비밀번호 확인 입력 필드 비우기
                            viewModel.checkPasswordMatch(); // 비밀번호 일치 여부 재확인
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          viewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off, // 비밀번호 가시성 상태에 따라 아이콘 변경
                        ),
                        onPressed: () {
                          setState(() {
                            viewModel.isPasswordVisible = !viewModel.isPasswordVisible; // 비밀번호 가시성 상태 변경
                          });
                        },
                      ),
                    ],
                  ),
                ),
                obscureText: !viewModel.isPasswordVisible, // 비밀번호 가시성에 따라 숨김 처리
              ),

              // 비밀번호 일치 여부 메시지 표시
              if (viewModel.password.length >= 8 && viewModel.confirmPassword.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    viewModel.isPasswordMatch ? '일치한 비밀번호입니다.' : '비밀번호가 일치하지 않습니다.',
                    style: TextStyle(
                      color: viewModel.isPasswordMatch ? Colors.green : Colors.red,
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // 서비스 정책 안내 문구
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '서비스 가입을 위해 서비스 정책에 대한 동의가 필요합니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),

              // 서비스 정책 체크 박스
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      '서비스 정책',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    // 서비스 이용약관 동의
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.isTermsAccepted,
                          onChanged: (value) {
                            viewModel.toggleTermsAcceptance();
                          },
                        ),
                        Expanded(
                          child: Text(
                            '[필수] 서비스 이용약관에 동의합니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: _showTermsDialog, // 팝업 호출
                        ),
                      ],
                    ),

                    // 개인정보 처리 방침 동의
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.isPrivacyAccepted,
                          onChanged: (value) {
                            viewModel.togglePrivacyAcceptance();
                          },
                        ),
                        Expanded(
                          child: Text(
                            '[필수] 개인정보 처리 방침에 동의합니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: _showPrivacyDialog, // 팝업 호출
                        ),
                      ],
                    ),

                    // 마케팅 수신 동의
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.isMarketingAccepted,
                          onChanged: (value) {
                            viewModel.toggleMarketingAcceptance();
                          },
                        ),
                        Expanded(
                          child: Text(
                            '[선택] 마케팅 수신 동의 약관에 동의합니다.',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: _showMarketingDialog, // 팝업 호출
                        ),
                      ],
                    ),
                    Divider(), // 줄 추가

                    // 모든 이용 약관 동의
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.isAllAgreed,
                          onChanged: (value) {
                            setState(() {
                              viewModel.toggleAllAgreements(); // 전체 동의 체크박스 토글
                              if (value == true) {
                                viewModel.isTermsAccepted = true; // 서비스 이용약관 체크
                                viewModel.isPrivacyAccepted = true; // 개인정보 처리 방침 체크
                                viewModel.isMarketingAccepted = false; // 마케팅 수신 동의는 선택사항이므로 체크 해제
                              } else {
                                viewModel.isTermsAccepted = false; // 서비스 이용약관 체크 해제
                                viewModel.isPrivacyAccepted = false; // 개인정보 처리 방침 체크 해제
                                viewModel.isMarketingAccepted = false; // 마케팅 수신 동의 체크 해제
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: Text('모든 이용 약관을 확인하였으며, 이에 동의합니다.'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 회원가입 버튼
              ElevatedButton(
                onPressed: viewModel.canSignUp
                    ? () {
                        viewModel.signUp(); // 회원가입 처리
                      }
                    : null, // 모든 내용을 작성하고 서비스 정책 체크하지 않으면 비활성화
                child: Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

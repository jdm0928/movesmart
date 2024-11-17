import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart'; // ViewModel
import 'login_screen.dart'; // 로그인 화면
import '../models/terms_of_service.dart'; // 서비스 이용 약관
import '../models/privacy_policy.dart'; // 개인정보 처리 방침
import '../models/marketing_consent.dart'; // 마케팅 수신 동의

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _localPartController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();

  final List<String> _domainList = [
    '직접 입력',
    'gmail.com',
    'naver.com',
    'daum.net',
    'nate.com'
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _localPartController.dispose();
    _domainController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameFocusNode.dispose();
    super.dispose();
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            bool? shouldExit = await viewModel.showExitConfirmationDialog(
                context);
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
              _buildNicknameField(viewModel),
              _buildEmailField(viewModel),
              _buildPasswordField(viewModel),
              _buildTermsSection(viewModel),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: viewModel.canSignUp
                          ? () => viewModel.signUp()
                          : null,
                      child: Text('가입하기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameField(SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          focusNode: _nicknameFocusNode,
          controller: _nicknameController..text = viewModel.nickname, // 닉네임을 ViewModel에서 가져옴
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.multiline,
          onChanged: (value) {
            viewModel.nickname = value; // ViewModel의 닉네임을 업데이트
          },
          decoration: InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
            suffixIcon: viewModel.nickname.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                viewModel.clearNickname(); // ViewModel에서 닉네임 초기화
                _nicknameController.clear(); // 닉네임 필드도 초기화
                setState(() {}); // UI 업데이트
              },
            )
                : null,
          ),
        ),
        if (viewModel.nicknameValidationMessage.message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              viewModel.nicknameValidationMessage.message,
              style: TextStyle(color: viewModel.nicknameValidationMessage.color),
            ),
          ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmailField(SignUpViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _localPartController,
                onChanged: (value) {
                  viewModel.onEmailChanged(value, _domainController.text);
                  setState(() {
                    // 이메일 유효성 추가 체크
                    viewModel.isEmailValid = viewModel.isEmailNotUsed &&
                        value.isNotEmpty &&
                        _domainController.text.isNotEmpty;
                  });
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
                      setState(() {});
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
                  viewModel.onEmailChanged(_localPartController.text, value);
                  setState(() {
                    // 이메일 유효성 추가 체크
                    viewModel.isEmailValid = viewModel.isEmailNotUsed &&
                        _localPartController.text.isNotEmpty &&
                        value.isNotEmpty;
                  });
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
                      setState(() {});
                    },
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(width: 16), // 도메인 입력 필드와 드롭다운 사이의 간격 추가
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
                  viewModel.onEmailChanged(
                      _localPartController.text, _domainController.text);
                }
              },
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  viewModel.emailValidationMessage.message,
                  style: TextStyle(
                    color: viewModel.emailValidationMessage.color,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: viewModel.isEmailNotUsed &&
                  viewModel.isEmailValid // 이메일 유효성 체크
                  ? () {
                String email = '${_localPartController.text}@${_domainController.text}';
                viewModel.sendVerificationEmail(email); // 이메일 인증 메서드 호출
              }
                  : null,
              child: Text('발송'),
            ),
          ],
        ),
        if (!viewModel.verificationMessage.message.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              viewModel.verificationMessage.message,
              style: TextStyle(color: viewModel.verificationMessage.color),
            ),
          ),
        if (viewModel.isEmailSent) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '남은 시간: ${viewModel.remainingTime ~/ 60} : ${viewModel.remainingTime % 60}',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPasswordField(SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          onChanged: (value) {
            viewModel.password = value;
            viewModel.checkPasswordComplexity();
            viewModel.checkPasswordMatch();
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: '비밀번호',
            border: OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.password.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      viewModel.clearPassword();
                      _passwordController.clear();
                      viewModel.confirmPassword = '';
                      _confirmPasswordController.clear();
                      viewModel.checkPasswordMatch();
                    },
                  ),
                IconButton(
                  icon: Icon(
                      viewModel.isPasswordVisible ? Icons.visibility : Icons
                          .visibility_off),
                  onPressed: () {
                    setState(() {
                      viewModel.isPasswordVisible =
                      !viewModel.isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
          ),
          obscureText: !viewModel.isPasswordVisible,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [viewModel.passwordStrengthColor, Colors.grey],
                  stops: [
                    viewModel.passwordStrengthValue,
                    viewModel.passwordStrengthValue
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(width: 8),
            Text(
              viewModel.passwordStrengthMessage.message,
              style: TextStyle(
                color: viewModel.passwordStrengthMessage.message.contains('미흡')
                    ? Colors.red // 미흡일 때 빨간색
                    : viewModel.passwordStrengthMessage.message.contains('양호')
                    ? Colors.green // 양호일 때 초록색
                    : viewModel.passwordStrengthMessage.message.contains('강력')
                    ? Colors.blue // 강력일 때 파란색
                    : Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          onChanged: (value) {
            viewModel.confirmPassword = value;
            viewModel.checkPasswordMatch();
          },
          enabled: viewModel.password.length >= 8,
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            border: OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.confirmPassword.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      viewModel.confirmPassword = '';
                      _confirmPasswordController.clear();
                      viewModel.checkPasswordMatch();
                    },
                  ),
                IconButton(
                  icon: Icon(
                      viewModel.isPasswordVisible ? Icons.visibility : Icons
                          .visibility_off),
                  onPressed: () {
                    setState(() {
                      viewModel.isPasswordVisible =
                      !viewModel.isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
          ),
          obscureText: !viewModel.isPasswordVisible,
        ),
        if (viewModel.password.length >= 8 &&
            viewModel.confirmPassword.isNotEmpty)
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
      ],
    );
  }

  Widget _buildTermsSection(SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '서비스 가입을 위해 서비스 정책에 대한 동의가 필요합니다.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서비스 정책',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildTermsCheckbox(viewModel),
              _buildPrivacyCheckbox(viewModel),
              _buildMarketingCheckbox(viewModel),
              Divider(),
              _buildAllAgreedCheckbox(viewModel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(SignUpViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.isTermsAccepted,
          onChanged: (value) {
            viewModel.toggleTermsAcceptance();
            if (value == false) {
              viewModel.isAllAgreed = false;
            }
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
          onPressed: () => _showDialog('서비스 이용 약관', termsOfService),
        ),
      ],
    );
  }

  Widget _buildPrivacyCheckbox(SignUpViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.isPrivacyAccepted,
          onChanged: (value) {
            viewModel.togglePrivacyAcceptance();
            if (value == false) {
              viewModel.isAllAgreed = false;
            }
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
          onPressed: () => _showDialog('개인정보 처리 방침', privacyPolicy),
        ),
      ],
    );
  }

  Widget _buildMarketingCheckbox(SignUpViewModel viewModel) {
    return Row(
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
          onPressed: () => _showDialog('마케팅 수신 동의', marketingConsent),
        ),
      ],
    );
  }

  Widget _buildAllAgreedCheckbox(SignUpViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.isAllAgreed,
          onChanged: (value) {
            setState(() {
              viewModel.toggleAllAgreements();
              if (value == true) {
                viewModel.isTermsAccepted = true;
                viewModel.isPrivacyAccepted = true;
                // 마케팅 수신 동의 상태는 그대로 유지
              } else {
                viewModel.isTermsAccepted = false;
                viewModel.isPrivacyAccepted = false;
                viewModel.isMarketingAccepted = false;
              }
            });
          },
        ),
        Expanded(
          child: Text('모든 이용 약관을 확인하였으며, 이에 동의합니다.'),
        ),
      ],
    );
  }
}
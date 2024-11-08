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
  final TextEditingController _localPartController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

    // 닉네임 컨트롤러 초기화
    _nicknameController.text = viewModel.nickname;
    _nicknameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _nicknameController.text.length),
    );

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
          controller: _nicknameController,
          onChanged: (value) {
            viewModel.onNicknameChanged(value);
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
            suffixIcon: viewModel.nickname.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                viewModel.clearNickname();
                _nicknameController.clear();
                setState(() {});
              },
            )
                : null,
          ),
        ),
        if (!viewModel.isNicknameValid)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              viewModel.nicknameValidationMessage.message,
              style: TextStyle(
                  color: viewModel.nicknameValidationMessage.color),
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
                  setState(() {});
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
                  setState(() {});
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
                      color: viewModel.emailValidationMessage.color),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: viewModel.isEmailValid && !viewModel.isEmailSent
                  ? () {
                viewModel.validateAndSendEmail();
              }
                  : null,
              child: Text(viewModel.isEmailSent ? '재발송' : '발송'),
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
                    ? Colors.red
                    : viewModel.passwordStrengthMessage.message.contains('양호')
                    ? Colors.blue
                    : viewModel.passwordStrengthMessage.message.contains('강력')
                    ? Colors.green
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
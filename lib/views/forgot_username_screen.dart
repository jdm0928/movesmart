import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/forgot_username_viewmodel.dart';
import '../models/country_codes.dart';
import '../views/login_screen.dart'; // 로그인 화면 import

class ForgotUsernameScreen extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotUsernameViewModel(),
      child: Consumer<ForgotUsernameViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('아이디 찾기'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back), // 뒤로 가기 아이콘
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
                  );
                },
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 국가 코드 선택
                      Row(
                        children: [
                          Container(
                            width: 150,
                            child: DropdownButton<String>(
                              value: viewModel.countryCode,
                              isExpanded: true,
                              onChanged: (String? newValue) {
                                viewModel.countryCode = newValue!;
                                viewModel.notifyListeners();
                              },
                              items: countryCodes.map<DropdownMenuItem<String>>((CountryCode country) {
                                return DropdownMenuItem<String>(
                                  value: country.uniqueValue, // 고유값 사용
                                  child: Text('${country.country} (${country.code})'), // 국가 이름과 코드 조합
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // 전화번호 입력 필드
                      TextField(
                        onChanged: (value) {
                          viewModel.phoneNumber = value;
                        },
                        decoration: InputDecoration(labelText: '전화번호'),
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await viewModel.requestVerification(); // 인증 요청
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(viewModel.message)), // 메시지 표시
                              );
                            },
                            child: Text('인증 요청'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // 인증 코드 입력 필드
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(labelText: '인증 코드'),
                        maxLength: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await viewModel.verifyCode(_codeController.text); // 인증 코드 확인
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(viewModel.message)), // 메시지 표시
                              );
                            },
                            child: Text('인증하기'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // 인증 성공 시 이메일 표시
                      if (viewModel.email.isNotEmpty) ...[
                        Text(
                          '가입한 이메일: ${viewModel.email}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

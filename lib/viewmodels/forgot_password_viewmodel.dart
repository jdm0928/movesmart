import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ValidationMessage {
  final String message;
  final Color color;

  ValidationMessage(this.message, this.color);
}

class ForgotPasswordViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String email = '';
  bool isEmailValid = false;
  bool isEmailExists = false; // 이메일 존재 여부 확인 변수
  bool isEmailSent = false; // 비밀번호 재설정 링크 발송 여부
  ValidationMessage verificationMessage = ValidationMessage('', Colors.transparent);

  // 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // 이메일 입력 처리
  void onEmailChanged(String localPart, String domain) {
    email = '${localPart.trim()}@${domain.trim()}';

    if (localPart.isEmpty && domain.isEmpty) {
      isEmailValid = false;
      verificationMessage = ValidationMessage('', Colors.transparent);
    } else if (localPart.isEmpty || domain.isEmpty) {
      _setEmailInvalid('유효한 이메일을 입력해주세요.');
    } else if (_isValidEmail(email)) {
      isEmailValid = true;
      verificationMessage = ValidationMessage('', Colors.transparent);
    } else {
      _setEmailInvalid('이메일 주소를 확인해주세요.');
    }

    notifyListeners(); // UI 업데이트
  }

  // 이메일 유효성 상태 설정
  void _setEmailInvalid(String message) {
    isEmailValid = false;
    verificationMessage = ValidationMessage(message, Colors.red);
  }

  // 이메일 존재 여부 확인
  Future<void> checkEmailExists() async {
    if (!isEmailValid) {
      verificationMessage = ValidationMessage('유효한 이메일 주소를 입력하세요.', Colors.red);
      notifyListeners();
      return;
    }

    try {
      // Firebase Realtime Database에서 이메일 존재 여부 확인
      final snapshot = await _database.child('users').orderByChild('email').equalTo(email).once();

      isEmailExists = (snapshot.snapshot.value != null); // 이메일이 존재하는지 확인

      if (isEmailExists) {
        verificationMessage = ValidationMessage('이메일이 확인되었습니다.', Colors.green);
      } else {
        verificationMessage = ValidationMessage('이메일이 등록되어 있지 않습니다.', Colors.red);
      }
    } catch (e) {
      verificationMessage = ValidationMessage('이메일 확인 중 오류가 발생했습니다: ${e.toString()}', Colors.red);
    }

    notifyListeners(); // UI 업데이트
  }

  // 비밀번호 재설정 링크 발송
  Future<void> sendPasswordResetEmail() async {
    if (!isEmailValid) {
      verificationMessage = ValidationMessage('유효한 이메일 주소를 입력하세요.', Colors.red);
      notifyListeners();
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      isEmailSent = true; // 링크가 발송되었음을 표시
      verificationMessage = ValidationMessage('비밀번호 재설정 링크가 발송되었습니다. 메일함을 확인해주세요.', Colors.green);
    } catch (e) {
      verificationMessage = ValidationMessage('비밀번호 재설정 링크 발송 중 오류가 발생했습니다: ${e.toString()}', Colors.red);
    }

    notifyListeners();
  }
}

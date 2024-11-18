import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../views/login_screen.dart';

class ValidationMessage {
  final String message;
  final Color color;

  ValidationMessage(this.message, this.color);
}

class SignUpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // 메시지 저장 변수
  ValidationMessage nicknameValidationMessage = ValidationMessage('', Colors.black);
  ValidationMessage emailValidationMessage = ValidationMessage('', Colors.black);
  ValidationMessage verificationMessage = ValidationMessage('', Colors.black);
  ValidationMessage passwordStrengthMessage = ValidationMessage('', Colors.black);
  ValidationMessage signUpButtonMessage = ValidationMessage('', Colors.black);

  // 사용자 정보 관련 변수
  String nickname = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phoneNumber = '';

  // 유효성 관련 변수
  bool isNicknameValid = true;
  bool isEmailValid = false;
  bool isEmailNotUsed = true;
  bool isNicknameNotUsed = true;
  bool isPasswordMatch = false;
  bool isPasswordVisible = false;

  // 비밀번호 강도 관련 변수
  Color passwordStrengthColor = Colors.black;
  double passwordStrengthValue = 0.0;

  String nicknameErrorMessage = ''; // 닉네임 에러 메시지
  DateTime? verificationRequestTime; // 인증 요청 시간
  bool canResend = true; // 재발송 버튼 쿨타임 관리

  // 회원가입 가능 여부 체크
  bool get canSignUp {
    return isNicknameValid &&
        isEmailValid &&
        isEmailNotUsed && // 이메일 중복성 체크
        isNicknameNotUsed && // 닉네임 중복성 체크
        password.length >= 8 && // 비밀번호 유효성
        isPasswordMatch && // 비밀번호 확인 일치 여부
        isTermsAccepted && // 이용 약관 동의 여부
        isPrivacyAccepted; // 개인정보 처리 방침 동의 여부
  }

  // 서비스 정책 동의 관련 변수
  bool isTermsAccepted = false;
  bool isPrivacyAccepted = false;
  bool isMarketingAccepted = false;
  bool isAllAgreed = false;

  int remainingTime = 60; // 1분을 초 단위로 나타냄
  Timer? _timer;

  // 생성자
  SignUpViewModel() {
    resetFields();
  }

  // 초기화 메서드
  void resetFields() {
    nickname = '';
    email = '';
    password = '';
    confirmPassword = '';

    isEmailValid = false;
    isNicknameValid = true;
    isPasswordMatch = false;

    nicknameValidationMessage = emailValidationMessage = verificationMessage = ValidationMessage('', Colors.black);

    notifyListeners();
  }

  // 닉네임 입력 처리
  void onNicknameChanged(String value) {
    nickname = value;
    isNicknameValid = value.isNotEmpty && value.length <= 15; // 15자 이상 체크

    if (nickname.isEmpty) {
      isNicknameValid = false;
      nicknameValidationMessage = ValidationMessage('', Colors.black);
    } else if (!RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(nickname)) {
      nicknameValidationMessage = ValidationMessage('닉네임은 문자, 숫자 또는 한글로만 작성해주세요.', Colors.red);
      isNicknameValid = false;
    } else {
      nicknameValidationMessage = ValidationMessage('중복 여부 확인해주세요.', Colors.green);
      isNicknameValid = true;
    }

    notifyListeners();
  }

  // 닉네임 초기화
  void clearNickname() {
    nickname = ''; // 닉네임을 빈 문자열로 설정
    isNicknameValid = true; // 초기화 후 유효성 재설정
    nicknameValidationMessage = ValidationMessage('', Colors.black); // 에러 메시지 초기화
    notifyListeners(); // UI 업데이트
  }

  // 닉네임 중복 확인
  Future<void> checkNicknameInUse(String nickname) async {
    try {
      // Firebase Realtime Database에서 닉네임 중복 확인
      final snapshot = await _database.child('users').orderByChild('nickname').equalTo(nickname).once();

      isNicknameNotUsed = (snapshot.snapshot.value == null); // 중복 여부 설정

      if (isNicknameNotUsed) {
        nicknameValidationMessage = ValidationMessage('사용 가능한 닉네임입니다.', Colors.green);
      } else {
        nicknameValidationMessage = ValidationMessage('이미 사용 중인 닉네임입니다.', Colors.red);
      }
    } catch (e) {
      nicknameValidationMessage = ValidationMessage('닉네임 확인 중 오류가 발생했습니다.', Colors.red);
    }

    notifyListeners(); // UI 업데이트
  }

  // 이메일 입력 처리
  void onEmailChanged(String localPart, String domain) {
    email = '${localPart.trim()}@${domain.trim()}';

    if (localPart.isEmpty && domain.isEmpty) {
      isEmailValid = false;
      emailValidationMessage = ValidationMessage('', Colors.transparent);
    } else if (localPart.isEmpty || domain.isEmpty) {
      _setEmailInvalid('유효한 이메일을 입력해주세요.');
    } else if (_isValidEmail(email)) {
      isEmailValid = true;
      emailValidationMessage = ValidationMessage('중복 여부 확인해주세요.', Colors.green);
    } else {
      _setEmailInvalid('이메일 주소를 확인해주세요.');
    }

    notifyListeners(); // UI 업데이트
  }

  // 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]{1,20}@[a-zA-Z0-9.-]{1,30}\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // 이메일 유효성 상태 설정
  void _setEmailInvalid(String message) {
    isEmailValid = false;
    emailValidationMessage = ValidationMessage(message, Colors.red);
  }

  // 이메일 중복 확인
  Future<void> checkEmailInUse(String email) async {
    try {
      // Firebase Realtime Database에서 이메일 중복 확인
      final snapshot = await _database.child('users').orderByChild('email').equalTo(email).once();

      isEmailNotUsed = (snapshot.snapshot.value == null); // 중복 여부 설정

      if (isEmailNotUsed) {
        emailValidationMessage = ValidationMessage('사용 가능한 이메일입니다.', Colors.green);
      } else {
        emailValidationMessage = ValidationMessage('이미 사용 중인 이메일 주소입니다.', Colors.red);
      }
    } catch (e) {
      emailValidationMessage = ValidationMessage('이메일 확인 중 오류가 발생했습니다.', Colors.red);
    }

    notifyListeners(); // UI 업데이트
  }

  // 비밀번호 복잡성 체크
  void checkPasswordComplexity() {
    passwordStrengthValue = 0; // 게이지 바 초기화

    // 비밀번호가 비어 있거나 8자 미만인 경우
    if (password.isEmpty || password.length < 8) {
      passwordStrengthColor = Colors.red;
      passwordStrengthMessage = ValidationMessage('최소 8자 이상 작성해주세요.', Colors.red);
    } else {
      // 비밀번호 길이가 8자 이상인 경우
      bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password); // 대문자 체크
      bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password); // 소문자 체크
      bool hasDigit = RegExp(r'\d').hasMatch(password); // 숫자 체크
      bool hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(password); // 특수문자 체크

      // 비밀번호 길이가 8자 이상 10자 미만인 경우
      if (password.length < 10) {
        if (!(hasLowerCase && hasDigit && hasSpecialChar)) {
          passwordStrengthColor = Colors.red;
          passwordStrengthMessage = ValidationMessage('비밀번호 안정성: 미흡', Colors.red);
          passwordStrengthValue = 1 / 3; // 1/3 채움
        } else {
          passwordStrengthColor = Colors.green; // 양호일 때 초록색
          passwordStrengthMessage = ValidationMessage('비밀번호 안정성: 양호', Colors.green);
          passwordStrengthValue = 2 / 3; // 2/3 채움
        }
      } else {
        // 비밀번호 길이가 10자 이상인 경우Q
        if (hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar) {
          passwordStrengthColor = Colors.blue; // 강력일 때 파란색
          passwordStrengthMessage = ValidationMessage('비밀번호 안정성: 강력', Colors.blue);
          passwordStrengthValue = 1.0; // 3/3 채움
        } else {
          passwordStrengthColor = Colors.green; // 강력하지 않지만 양호일 경우 노란색
          passwordStrengthMessage = ValidationMessage('비밀번호 안정성: 양호', Colors.green);
          passwordStrengthValue = 2 / 3; // 2/3 채움
        }
      }
    }

    notifyListeners(); // UI 업데이트
  }

  // 비밀번호 확인 체크
  void checkPasswordMatch() {
    isPasswordMatch = (password == confirmPassword);
    notifyListeners();
  }

  // 비밀번호 초기화 메서드
  void clearPassword() {
    password = '';
    checkPasswordComplexity(); // 비밀번호 복잡성 재확인
    notifyListeners();
  }

  // 서비스 이용 약관 동의 체크
  void toggleTermsAcceptance() {
    isTermsAccepted = !isTermsAccepted;
    notifyListeners();
  }

  // 개인 정보 처리 동의 체크
  void togglePrivacyAcceptance() {
    isPrivacyAccepted = !isPrivacyAccepted;
    notifyListeners();
  }

  // 마케팅 수신 동의 체크
  void toggleMarketingAcceptance() {
    isMarketingAccepted = !isMarketingAccepted;
    notifyListeners();
  }

  // 모든 이용 약관 동의 체크
  void toggleAllAgreements() {
    isAllAgreed = !isAllAgreed;
    notifyListeners();
  }

  // 회원가입 처리 메서드
  Future<void> signUp(BuildContext context) async {
    if (canSignUp) {
      try {
        // Firebase Authentication을 사용하여 사용자 생성
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 기본 이미지 URL (예: 기본 프로필 이미지 URL)
        String defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/movesmart-86652.firebasestorage.app/o/default_profile_image.png?alt=media&token=46d7ba1c-ef3f-4a94-9a77-b89824691331';

        // 추가적인 사용자 정보 저장 로직 (Firebase Realtime Database에 사용자 정보 저장)
        await _database.child('users/${userCredential.user!.uid}').set({
          'nickname': nickname,
          'email': email,
          'phoneNumber': phoneNumber,
          'marketingAccepted': isMarketingAccepted,
          'profileImageUrl': defaultImageUrl,
        });

        // 회원가입 성공 메시지 설정
        signUpButtonMessage = ValidationMessage('회원가입이 성공적으로 완료되었습니다.', Colors.green);
        notifyListeners();

        // 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

      } catch (e) {
        signUpButtonMessage = ValidationMessage('회원가입 중 오류가 발생했습니다: ${e.toString()}', Colors.red);
        notifyListeners();
      }
    } else {
      signUpButtonMessage = ValidationMessage('모든 필드를 올바르게 입력해주세요.', Colors.red);
      notifyListeners();
    }
  }

  // 회원가입 중단 확인 팝업 로직에서 초기화 메서드 호출
  Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('회원가입을 완료하지 않았습니다.\n회원가입을 중단하고 돌아가시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('예'),
              onPressed: () {
                resetFields(); // 초기화 메서드 호출
                Navigator.of(context).pop(true); // '예' 선택 시 true 반환
              },
            ),
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(false); // '아니오' 선택 시 false 반환
              },
            ),
          ],
        );
      },
    );
  }

  // 메모리 해제 시 타이머 취소
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}



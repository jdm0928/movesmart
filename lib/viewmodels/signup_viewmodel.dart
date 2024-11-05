import 'dart:async'; // Timer 클래스를 사용하기 위한 import
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Firebase Database 참조

  // 닉네임 관련 변수
  String nickname = '';
  bool isNicknameValid = true; // 닉네임 유효성
  String nicknameErrorMessage = '';

  // 이메일 관련 변수
  String email = '';
  bool isEmailValid = false; // 이메일 유효성
  String emailErrorMessage = '';
  bool isEmailSent = false; // 이메일 인증 발송 여부
  Timer? _timer; // 인증 메일 유효 시간 타이머

  // 비밀번호 관련 변수
  bool isPasswordVisible = false; // 비밀번호 가시성 상태
  String password = ''; // 비밀번호 변수 추가
  String confirmPassword = ''; // 비밀번호 확인 변수 추가
  bool isPasswordMatch = false; // 비밀번호 일치 여부
  Color passwordStrengthColor = Colors.black; // 초기 색상
  String passwordStrengthMessage = '최소 8자 이상 작성해주세요.'; // 초기 메시지
  double passwordStrengthValue = 0.0; // 비밀번호 강도 값 (0.0 ~ 1.0)

  // 서비스 정책 체크 변수
  bool isTermsAccepted = false; // 서비스 이용약관 동의 여부
  bool isPrivacyAccepted = false; // 개인정보 처리 방침 동의 여부
  bool isMarketingAccepted = false; // 마케팅 수신 동의 여부
  bool isAllAgreed = false; // 모든 이용 약관 동의 여부

  // 닉네임 입력 처리
  void onNicknameChanged(String value) {
    nickname = value;
    isNicknameValid = value.isNotEmpty; // 입력된 값이 있을 경우 유효하다고 설정

    // 기본 유효성 검사
    if (nickname.isEmpty) {
      nicknameErrorMessage = ''; // 비어 있으면 에러 메시지 제거
      isNicknameValid = false;
    } else if (nickname.length > 15) {
      nicknameErrorMessage = '닉네임은 15자 이하로 작성해주세요.';
      isNicknameValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(nickname)) {
      nicknameErrorMessage = '닉네임은 문자와 숫자로만 작성해주세요.';
      isNicknameValid = false;
    } else {
      nicknameErrorMessage = ''; // 유효한 경우 에러 메시지 제거
      isNicknameValid = true;
    }

    notifyListeners(); // UI 업데이트
  }

  // 닉네임 초기화
  void clearNickname() {
    nickname = ''; // 닉네임을 빈 문자열로 설정
    isNicknameValid = true; // 초기화 후 유효성 재설정
    nicknameErrorMessage = ''; // 에러 메시지 초기화
    notifyListeners(); // UI 업데이트
  }

  // 이메일 입력 처리 (로컬과 도메인 부분)
  void onEmailChanged(String localPart, String domain) {
    email = '$localPart@$domain'; // 이메일을 로컬과 도메인으로 조합

    // 이메일이 비어 있는 경우 에러 메시지 초기화
    if (email.isEmpty) {
      isEmailValid = false;
      emailErrorMessage = ''; // 비어 있을 때 에러 메시지 제거
    } else {
      // 이메일 형식 유효성 검사
      if (RegExp(r'^[a-zA-Z0-9._%+-]{1,20}@[a-zA-Z0-9.-]{1,30}\.[a-zA-Z]{2,}$').hasMatch(email)) {
        isEmailValid = true;
        emailErrorMessage = '';
        // 발송 버튼 활성화 조건 체크
        if (!isEmailSent) {
          checkEmailInUse(email);
        }
      } else {
        isEmailValid = false;
        emailErrorMessage = '이메일 주소를 확인해주세요.';
      }
    }
    notifyListeners();
  }

  // 이메일 중복 확인
  Future<void> checkEmailInUse(String email) async {
    try {
      await _auth.fetchSignInMethodsForEmail(email).then((methods) {
        if (methods.isNotEmpty) {
          isEmailValid = false;
          emailErrorMessage = '이미 사용 중인 이메일 주소입니다.';
        } else {
          isEmailValid = true;
          emailErrorMessage = '';
        }
        notifyListeners();
      });
    } catch (e) {
      emailErrorMessage = '이메일 확인 중 오류가 발생했습니다.';
      notifyListeners();
    }
  }

  // 이메일 인증 발송
  Future<void> sendVerificationEmail() async {
    if (isEmailValid && email.isNotEmpty) {
      try {
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://5a2a-61-253-40-30.ngrok-free.app', // 인증 후 리디렉션 URL
          handleCodeInApp: true, // 앱 내에서 처리할지 여부
        );

        // 이메일 인증 링크 발송
        await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: actionCodeSettings);
        isEmailSent = true;
        emailErrorMessage = '입력하신 이메일 주소로 인증 메일을 보내드렸습니다. 메일함을 확인해주세요.';
        startTimer(); // 인증 메일 유효 시간 시작
      } catch (e) {
        emailErrorMessage = '인증 메일 발송 중 오류가 발생했습니다.';
      }
      notifyListeners();
    }
  }

  // 인증 메일 유효 시간 타이머 시작
  void startTimer() {
    _timer = Timer(Duration(minutes: 3), () {
      isEmailSent = false;
      emailErrorMessage = '인증 메일의 유효 기간이 만료되었습니다. 인증 메일을 재발송 해주세요.';
      notifyListeners();
    });
  }

  // 비밀번호 복잡성 체크
  void checkPasswordComplexity() {
    if (password.isEmpty || password.length < 8) {
      passwordStrengthColor = Colors.red;
      passwordStrengthMessage = '최소 8자 이상 작성해주세요.';
      passwordStrengthValue = 0; // 게이지 바 초기화
    } else if (password.length < 10) {
      // 8자 이상 10자 미만
      bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      bool hasDigit = RegExp(r'\d').hasMatch(password);
      bool hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(password);

      if (!(hasLetter && hasDigit && hasSpecialChar)) {
        passwordStrengthColor = Colors.red;
        passwordStrengthMessage = '비밀번호 안정성: 미흡';
        passwordStrengthValue = 1 / 3; // 1/3 채움
      } else {
        passwordStrengthColor = Colors.blue;
        passwordStrengthMessage = '비밀번호 안정성: 양호';
        passwordStrengthValue = 2 / 3; // 2/3 채움
      }
    } else {
      // 10자 이상
      bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      bool hasDigit = RegExp(r'\d').hasMatch(password);
      bool hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(password);

      if (hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar) {
        passwordStrengthColor = Colors.green;
        passwordStrengthMessage = '비밀번호 안정성: 강력';
        passwordStrengthValue = 1.0; // 3/3 채움
      } else {
        passwordStrengthColor = Colors.blue;
        passwordStrengthMessage = '비밀번호 안정성: 양호';
        passwordStrengthValue = 2 / 3; // 2/3 채움
      }
    }
    notifyListeners();
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

  // 회원가입 가능 여부 체크
  bool get canSignUp {
    return isEmailValid && nickname.isNotEmpty && password.length >= 9
        && isPasswordMatch && isTermsAccepted && isPrivacyAccepted;
  }

  // 서비스 정책 체크
  void toggleTermsAcceptance() {
    isTermsAccepted = !isTermsAccepted;
    notifyListeners();
  }

  void togglePrivacyAcceptance() {
    isPrivacyAccepted = !isPrivacyAccepted;
    notifyListeners();
  }

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
  Future<void> signUp() async {
    if (canSignUp) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 추가적인 사용자 정보 저장 로직 (예: Firebase Database에 사용자 정보 저장)
        await _database.child('users/${userCredential.user!.uid}').set({
          'nickname': nickname,
          'email': email,
        });

        // 회원가입 후 추가적인 처리 (예: 메인 화면으로 이동 등)
      } catch (e) {
        emailErrorMessage = '회원가입 중 오류가 발생했습니다: ${e.toString()}';
        notifyListeners();
      }
    } else {
      emailErrorMessage = '모든 필드를 올바르게 입력해주세요.';
      notifyListeners();
    }
  }

  // 회원가입 중단 확인 팝업 로직
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



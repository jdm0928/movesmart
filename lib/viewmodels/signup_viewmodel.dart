import 'dart:async'; // Timer 클래스를 사용하기 위한 import
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  // 유효성 관련 변수
  bool isNicknameValid = true;
  bool isEmailValid = false;
  bool isEmailNotUsed = true;
  bool isEmailSent = false;
  bool isEmailConfirmed = false;
  bool isPasswordMatch = false;
  bool isPasswordVisible = false;

  // 비밀번호 강도 관련 변수
  Color passwordStrengthColor = Colors.black;
  double passwordStrengthValue = 0.0;

  // 추가된 변수
  String nicknameErrorMessage = ''; // 닉네임 에러 메시지
  DateTime? verificationRequestTime; // 인증 요청 시간
  bool canResend = true; // 재발송 버튼 쿨타임 관리

  // 회원가입 가능 여부 체크
  bool get canSignUp {
    return isNicknameValid &&
        isEmailValid &&
        isEmailNotUsed && // 이메일 중복성 체크
        isEmailConfirmed &&
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
    isEmailSent = false;
    isEmailConfirmed = false;
    isNicknameValid = true;
    isPasswordMatch = false;

    nicknameValidationMessage = ValidationMessage('', Colors.black);
    emailValidationMessage = ValidationMessage('', Colors.black);
    verificationMessage = ValidationMessage('', Colors.black);
    passwordStrengthMessage = ValidationMessage('', Colors.black);

    notifyListeners();
  }

  // 닉네임 입력 처리
  void onNicknameChanged(String value) {
    nickname = value;
    isNicknameValid = value.isNotEmpty && value.length <= 15; // 15자 이상 체크

    if (nickname.isEmpty) {
      isNicknameValid = false;
      nicknameValidationMessage = ValidationMessage('', Colors.black); // 비어 있으면 메시지 제거
    } else if (!RegExp(r'^[a-zA-Z0-9가-힣]*$').hasMatch(nickname)) {
      nicknameValidationMessage = ValidationMessage('닉네임은 문자, 숫자 또는 한글로만 작성해주세요.', Colors.red);
      isNicknameValid = false;
    } else {
      nicknameValidationMessage = ValidationMessage('사용 가능한 닉네임입니다.', Colors.green);
      isNicknameValid = true;
    }

    notifyListeners(); // UI 업데이트
  }

  // 닉네임 초기화
  void clearNickname() {
    nickname = ''; // 닉네임을 빈 문자열로 설정
    isNicknameValid = true; // 초기화 후 유효성 재설정
    nicknameValidationMessage = ValidationMessage('', Colors.black); // 에러 메시지 초기화
    notifyListeners(); // UI 업데이트
  }

  void onEmailChanged(String localPart, String domain) {
    // 이메일을 로컬과 도메인으로 조합
    email = '${localPart.trim()}@${domain.trim()}';

    // 아무것도 작성하지 않은 경우
    if (localPart.isEmpty && domain.isEmpty) {
      // ValidationMessage를 설정하지 않음
      isEmailValid = false; // 이메일 유효성 초기화
      emailValidationMessage = ValidationMessage('', Colors.transparent); // 메시지 초기화
    }
    // 로컬 또는 도메인 중 하나만 작성된 경우
    else if (localPart.isEmpty || domain.isEmpty) {
      _setEmailInvalid('유효한 이메일을 입력해주세요.');
    }
    // 유효한 형식의 이메일인 경우 (둘 다 작성)
    else if (_isValidEmail(email)) {
      isEmailValid = true;
      emailValidationMessage = ValidationMessage('사용 가능한 이메일입니다.', Colors.green);
    }
    // 유효하지 않은 이메일인 경우
    else {
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
    isEmailSent = false; // 이메일 발송 버튼 비활성화
  }

// 이메일 발송 전 중복 확인 및 발송 처리
  Future<void> validateAndSendEmail() async {
    if (!isEmailValid) {
      _setEmailInvalid('유효한 이메일을 입력해주세요.');
      return; // 유효하지 않은 이메일일 때 조기에 종료
    }

    await checkEmailInUse(email);

    if (isEmailValid && isEmailNotUsed) { // 중복되지 않는 경우
      emailValidationMessage = ValidationMessage('사용 가능한 이메일입니다.', Colors.green);
      await sendVerificationEmail(); // 인증 메일 발송
    }
  }

// 이메일 중복 확인
  Future<void> checkEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      isEmailNotUsed = methods.isEmpty; // 중복 여부 설정
      isEmailValid = isEmailNotUsed; // 중복 여부에 따라 유효성 설정
      emailValidationMessage = isEmailNotUsed
          ? ValidationMessage('', Colors.black) // 중복이 아닐 경우 메시지 제거
          : ValidationMessage('이미 사용 중인 이메일 주소입니다.', Colors.red); // 중복되는 이메일 메시지
    } catch (e) {
      emailValidationMessage = ValidationMessage('이메일 확인 중 오류가 발생했습니다.', Colors.red); // 오류 발생 메시지
    }

    notifyListeners(); // UI 업데이트
  }

// 이메일 인증 발송
  Future<void> sendVerificationEmail() async {
    if (isEmailValid && email.isNotEmpty) {
      try {
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://jdm0928.github.io/movesmart?email=${Uri.encodeComponent(email)}', // 인증 후 리디렉션 URL
          handleCodeInApp: true, // 앱 내에서 처리할지 여부
        );

        await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: actionCodeSettings);
        isEmailSent = true;
        verificationRequestTime = DateTime.now(); // 인증 요청 시간 기록
        verificationMessage = ValidationMessage('입력하신 이메일 주소로 인증 메일을 보내드렸습니다. 메일함을 확인해주세요.', Colors.green); // 메일 전송 성공 메시지
        startTimer(); // 인증 메일 유효 시간 시작
      } catch (e) {
        verificationMessage = ValidationMessage('인증 메일 발송 중 오류가 발생했습니다.', Colors.red); // 메일 발송 오류 메시지
      }

      notifyListeners(); // UI 업데이트
    }
  }

// 인증 메일 유효 시간 타이머 시작
  void startTimer() {
    _timer?.cancel(); // 이전 타이머 취소
    _timer = Timer(Duration(minutes: 3), () {
      isEmailSent = false;
      verificationMessage = ValidationMessage('인증 메일의 유효 기간이 만료되었습니다. \n인증 메일을 재발송 해주세요.', Colors.red);
      notifyListeners();
    });
  }

// 재발송 처리
  Future<void> resendVerificationEmail() async {
    if (canResend && isEmailValid && email.isNotEmpty) {
      canResend = false; // 쿨타임 시작
      verificationMessage = ValidationMessage('', Colors.black); // 이전 메시지 초기화
      await sendVerificationEmail(); // 이메일 재발송

      // 쿨타임 설정
      Timer(Duration(seconds: 10), () {
        canResend = true; // 쿨타임 해제
        notifyListeners();
      });
    }
  }

// 인증 성공 처리
  void confirmEmailVerification() {
    isEmailConfirmed = true;
    verificationMessage = ValidationMessage('인증되었습니다.', Colors.green); // 인증 완료 메시지
    email = ''; // 이메일 입력 비활성화
    isEmailValid = false; // 이메일 수정 불가
    isEmailSent = false; // 이메일 발송 버튼 비활성화
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
          passwordStrengthColor = Colors.green;
          passwordStrengthMessage = ValidationMessage('비밀번호 안정성: 양호', Colors.green);
          passwordStrengthValue = 2 / 3; // 2/3 채움
        }
      } else {
        // 비밀번호 길이가 10자 이상인 경우
        if (hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar) {
          passwordStrengthColor = Colors.blue;
          passwordStrengthMessage = ValidationMessage('비밀번호 안정성: 강력', Colors.blue);
          passwordStrengthValue = 1.0; // 3/3 채움
        } else {
          passwordStrengthColor = Colors.green;
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
          'marketingAccepted': isMarketingAccepted, // 마케팅 수신 동의 여부 저장
        });

        // 회원가입 후 추가적인 처리 (예: 메인 화면으로 이동 등)
      } catch (e) {
        signUpButtonMessage = ValidationMessage('회원가입 중 오류가 발생했습니다: ${e.toString()}', Colors.red); // 오류 발생 메시지
        notifyListeners();
      }
    } else {
      signUpButtonMessage = ValidationMessage('모든 필드를 올바르게 입력해주세요.', Colors.red); // 모든 필드 오류 메시지
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



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Realtime Database
import 'package:movesmart/views/login_screen.dart';
import '../services/navigation_service.dart';

class SignUpViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Realtime Database 인스턴스 생성
  final NavigationService _navigationService = NavigationService(); // NavigationService 인스턴스 생성

  String verificationId = '';
  bool _isTimerActive = false;
  int _remainingTime = 60;

  // 회원가입 함수
  Future<void> signUp(BuildContext context, String nickname, String username, String email, String password, String phone, String verificationCode) async {
    if (nickname.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty || verificationCode.isEmpty) {
      _showError(context, '모든 필드를 입력하세요.');
      return;
    }

    // 비밀번호 확인
    if (password.length < 8) {
      _showError(context, '비밀번호는 8자 이상이어야 합니다.');
      return;
    }

    // 인증 코드 확인
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: verificationCode);
      await _auth.signInWithCredential(credential);
    } catch (e) {
      _showError(context, '인증 코드가 유효하지 않습니다.');
      return;
    }

    // 중복 아이디 및 이메일 확인
    final snapshot = await _database.child('users').orderByChild('username').equalTo(username).once();
    final emailSnapshot = await _database.child('users').orderByChild('email').equalTo(email).once();

    if (snapshot.snapshot.exists) {
      _showError(context, '이미 사용 중인 아이디입니다.');
      return;
    } else if (emailSnapshot.snapshot.exists) {
      _showError(context, '이미 가입된 이메일입니다.');
      return;
    }

    try {
      // Firebase Authentication을 사용하여 회원가입
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 회원가입 성공 시 Realtime Database에 추가 정보 저장
      if (userCredential.user != null) {
        String userId = userCredential.user!.uid; // 사용자 ID

        // 사용자 정보를 Realtime Database에 저장
        await _database.child('users/$userId').set({
          'nickname': nickname,
          'username': username,
          'email': email,
          'phone': phone,
          'createdAt': DateTime.now().toIso8601String(), // 생성 시간
        });

        // 성공 알림 표시
        _showSuccess(context, '회원 가입이 완료되었습니다!');

        // 로그인 화면으로 이동
        _navigationService.navigateTo(context, LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      // 회원가입 실패 시 에러 메시지 표시
      if (e.code == 'email-already-in-use') {
        _showError(context, '이 이메일은 이미 사용 중입니다.');
      } else if (e.code == 'weak-password') {
        _showError(context, '비밀번호는 8자 이상이어야 합니다.');
      } else {
        _showError(context, '회원가입 실패: ${e.message}');
      }
    }
  }

  // 아이디 중복 확인 함수
  Future<bool> checkUsername(BuildContext context, String username) async {
    final snapshot = await _database.child('users').orderByChild('username').equalTo(username).once();
    if (snapshot.snapshot.exists) {
      return false; // 중복된 아이디
    } else {
      return true; // 사용 가능한 아이디
    }
  }

  // 전화번호 인증 함수
  Future<void> sendVerificationCode(BuildContext context, String phone, String countryCode) async {
    // E.164 형식으로 전화번호 변환 (예: +821012345678)
    String formattedPhone = countryCode + phone.replaceFirst(RegExp(r'^0'), ''); // 선택한 국가 코드 사용

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 자동으로 인증이 완료된 경우
        await _auth.signInWithCredential(credential);
        _showSuccess(context, '전화번호 인증이 완료되었습니다.');
      },
      verificationFailed: (FirebaseAuthException e) {
        _showError(context, '전화번호 인증 실패: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId; // verificationId 저장
        _showSuccess(context, '인증 코드가 발송되었습니다.');
        startTimer(); // 타이머 시작
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  // 타이머 시작 함수
  void startTimer() {
    if (_isTimerActive) return; // 타이머가 이미 활성화되어 있다면 리턴
    _isTimerActive = true; // 타이머 활성화
    _remainingTime = 60; // 1분으로 초기화

    Future.delayed(Duration(seconds: 1), () {
      if (_remainingTime > 0) {
        _remainingTime--; // 남은 시간 감소
        startTimer(); // 재귀 호출로 타이머 계속 진행
      } else {
        _isTimerActive = false; // 타이머 종료
        // 타이머 종료 후 알림을 위해 context가 필요합니다.
      }
    });
  }

  // 타이머 상태 및 남은 시간 getter
  bool get isTimerActive => _isTimerActive; // 타이머 활성화 상태
  int get remainingTime => _remainingTime; // 남은 시간

  // 성공 메시지 표시 함수
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // 성공 메시지 색상
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }

  // 에러 메시지 표시 함수
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // 에러 메시지 색상
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }
}

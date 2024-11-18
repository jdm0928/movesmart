import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ForgotUsernameViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String phoneNumber = '';
  String countryCode = '+82-대한민국'; // 기본값으로 한국 국가 코드 설정
  String verificationId = '';
  String message = '';
  String email = '';

  // 전화번호로 인증 요청
  Future<void> requestVerification() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '$countryCode$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 자동으로 인증이 완료된 경우
          await _auth.signInWithCredential(credential);
          message = '인증 성공';
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          message = '인증 실패: ${e.message}';
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          message = '인증 코드가 SMS로 전송되었습니다.';
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      message = '전화번호 인증 요청 중 오류 발생: ${e.toString()}';
      notifyListeners();
    }
  }

  // 인증 코드 확인
  Future<void> verifyCode(String code) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await _auth.signInWithCredential(credential);
      message = '인증 성공!';
    } catch (e) {
      message = '인증 코드가 잘못되었습니다: ${e.toString()}';
    }
    notifyListeners();
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:kakao_flutter_sdk/all.dart'; // 카카오 SDK 불러오기
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movesmart/views/forgot_password_screen.dart';
import 'package:movesmart/views/forgot_username_screen.dart';
import '../services/navigation_service.dart';
import '../views/home_screen.dart';
import '../views/signup_screen.dart'; // SignUpScreen 임포트 추가

class LoginViewModel extends ChangeNotifier {
  final NavigationService _navigationService = NavigationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 로그인 함수 (이메일/비밀번호)
  Future<void> login(BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError(context, '아이디와 비밀번호를 입력하세요.');
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      if (userCredential.user != null) {
        _navigateToHome(context);
      } else {
        _showError(context, '로그인 실패');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _showError(context, '해당 아이디가 존재하지 않습니다.');
          break;
        case 'wrong-password':
          _showError(context, '비밀번호가 잘못되었습니다.');
          break;
        default:
          _showError(context, '로그인 실패');
      }
    } catch (error) {
      _showError(context, '로그인 중 오류가 발생했습니다: $error');
    }
  }

  void setLanguageCode() {
    FirebaseAuth.instance.setLanguageCode('ko');
  }

  /// Firebase에 사용자 정보 저장 함수
  Future<void> _saveUserToDatabase(User? user, String nickname, String email, String profileImage) async {
    if (user == null) return;

    final userId = user.uid;
    final userData = {
      'nickname': nickname,
      'email': email,
      'profileImage': profileImage,
      'marketingConsent': false, // 기본값 설정
    };

    // Realtime Database에 사용자 정보 저장
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');
    await ref.set(userData);
  }

  /// 구글 로그인 함수
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // 사용자 정보를 Firebase Realtime Database에 저장
        await _saveUserToDatabase(userCredential.user, googleUser?.displayName ?? '', googleUser?.email ?? '', googleUser?.photoUrl ?? '');
        _showSuccess(context, '로그인 성공');
        _navigateToHome(context);
      } else {
        _showError(context, '로그인 실패');
      }
    } catch (error) {
      _showError(context, '구글 로그인 중 오류가 발생했습니다: $error');
    }
  }

  /// 카카오 로그인 함수
  // Future<void> signInWithKakao(BuildContext context) async {
  //   try {
  //     final isKakaoTalkInstalled = await isKakaoTalkInstalled();
  //
  //     String authCode;
  //     if (isKakaoTalkInstalled) {
  //       // 카카오톡이 설치된 경우
  //       authCode = await AuthCodeClient.instance.request();
  //     } else {
  //       // 카카오톡이 설치되지 않은 경우 웹 로그인으로 리디렉션
  //       final url = 'https://kauth.kakao.com/oauth/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=movesmart://auth&response_type=code';
  //       await launch(url);
  //       return; // 웹 로그인으로 리디렉션하므로 여기서 종료
  //     }
  //
  //     // Kakao 사용자 정보 요청
  //     final tokenResponse = await http.post(
  //       Uri.parse('https://kauth.kakao.com/oauth/token'),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: {
  //         'grant_type': 'authorization_code',
  //         'client_id': 'YOUR_CLIENT_ID', // REST API 키
  //         'redirect_uri': 'movesmart://auth', // Redirect URI
  //         'code': authCode,
  //       },
  //     );
  //
  //     if (tokenResponse.statusCode == 200) {
  //       final tokenData = json.decode(tokenResponse.body);
  //       final accessToken = tokenData['access_token'];
  //
  //       final userResponse = await http.get(
  //         Uri.parse('https://kapi.kakao.com/v2/user/me'),
  //         headers: {
  //           'Authorization': 'Bearer $accessToken',
  //         },
  //       );
  //
  //       if (userResponse.statusCode == 200) {
  //         final userData = json.decode(userResponse.body);
  //         final nickname = userData['kakao_account']['profile']['nickname'];
  //         final email = userData['kakao_account']['email'];
  //         final profileImage = userData['kakao_account']['profile']['profile_image'];
  //
  //         // Firebase에서 사용자 인증
  //         final credential = GoogleAuthProvider.credential(
  //           accessToken: accessToken,
  //           idToken: null, // 카카오는 ID 토큰이 없음
  //         );
  //         UserCredential userCredential = await _auth.signInWithCredential(credential);
  //
  //         // Firebase에 사용자 정보 저장
  //         await _saveUserToDatabase(userCredential.user, nickname, email, profileImage);
  //         _showSuccess(context, '로그인 성공: $nickname');
  //         _navigateToHome(context);
  //       } else {
  //         _showError(context, '사용자 정보를 가져오는 데 실패했습니다: ${userResponse.body}');
  //       }
  //     } else {
  //       _showError(context, '액세스 토큰 요청에 실패했습니다: ${tokenResponse.body}');
  //     }
  //   } catch (error) {
  //     _showError(context, '카카오 로그인 중 오류가 발생했습니다: $error');
  //   }
  // }

  /// 네이버 로그인 함수
  Future<void> signInWithNaver(BuildContext context) async {
    try {
      // 네이버 로그인 요청
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      // 액세스 토큰 가져오기
      final NaverAccessToken accessToken = result.accessToken;

      // 사용자 프로필 요청
      final userResponse = await http.get(
        Uri.parse('https://openapi.naver.com/v1/nid/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        final nickname = userData['response']['nickname']; // 사용자 닉네임
        final email = userData['response']['email']; // 사용자 이메일
        final profileImage = userData['response']['profile_image']; // 프로필 이미지 URL

        // Firebase에서 사용자 인증
        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken.tokenType + ' ' + accessToken.accessToken,
          idToken: null, // 네이버도 ID 토큰이 없음
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Firebase에 사용자 정보 저장
        await _saveUserToDatabase(userCredential.user, nickname, email, profileImage);
        _showSuccess(context, '로그인 성공: $nickname');
        _navigateToHome(context);
      } else {
        _showError(context, '사용자 정보를 가져오는 데 실패했습니다: ${userResponse.body}');
      }
    } catch (error) {
      _showError(context, '네이버 로그인 중 오류가 발생했습니다: $error');
    }
  }

  // 홈 화면으로 이동하는 함수
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // 성공 메시지 표시 함수
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }

  // 회원가입 화면으로 이동하는 함수
  void navigateToSignUp(BuildContext context) {
    _navigationService.navigateTo(context, SignUpScreen());
  }

  // 아이디 찾기 화면으로 이동하는 함수
  void navigateToForgotUsername(BuildContext context) {
    _navigationService.navigateTo(context, ForgotUsernameScreen());
  }

  // 비밀번호 찾기 화면으로 이동하는 함수
  void navigateToForgotPassword(BuildContext context) {
    _navigationService.navigateTo(context, ForgotPasswordScreen());
  }

  // 에러 메시지 표시 함수
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      ),
    );
  }
}

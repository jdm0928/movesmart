import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Firebase 인증
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart'; // 구글 로그인
import 'package:flutter_naver_login/flutter_naver_login.dart'; // 네이버 로그인
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao; // 카카오 로그인
import 'package:http/http.dart' as http; // HTTP 요청
import 'dart:convert'; // JSON 데이터 처리
import 'package:url_launcher/url_launcher.dart'; // URL 열기
import 'package:flutter/material.dart'; // Flutter UI
import '../views/forgot_password_screen.dart'; // 비밀번호 찾기 화면
import '../views/forgot_username_screen.dart'; // 아이디 찾기 화면
import '../views/home_screen.dart'; // 홈 화면
import '../views/signup_screen.dart'; // 회원가입 화면
import '../services/navigation_service.dart'; // 네비게이션 서비스


class LoginViewModel extends ChangeNotifier {
  final NavigationService _navigationService = NavigationService();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 로그인 함수 (이메일/비밀번호)
  Future<void> login(BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError(context, '아이디와 비밀번호를 입력하세요.');
      return;
    }

    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      if (userCredential.user != null) {
        _navigateToHome(context);
      } else {
        _showError(context, '로그인 실패');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e, context);
    } catch (error) {
      _showError(context, '로그인 중 오류가 발생했습니다: $error');
    }
  }

  void setLanguageCode() {
    firebase_auth.FirebaseAuth.instance.setLanguageCode('ko');
  }

  /// 구글 로그인 함수
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _handleUserProfile(userCredential.user, googleUser?.displayName, googleUser?.email, googleUser?.photoUrl, context);
    } catch (error) {
      _showError(context, '구글 로그인 중 오류가 발생했습니다: $error');
    }
  }

  /// 카카오 로그인 함수
  Future<void> signInWithKakao(BuildContext context) async {
    try {
      final bool isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();
      String authCode;

      if (isKakaoTalkInstalled) {
        authCode = await kakao.AuthCodeClient.instance.request();
      } else {
        final url = 'https://kauth.kakao.com/oauth/authorize?'
            'client_id=a185a267072df6495590e209e7af148b&'
            'redirect_uri=movesmart://auth&'
            'response_type=code';
        await launch(url);
        return; // 웹 로그인으로 리디렉션하므로 여기서 종료
      }

      final tokenResponse = await _getKakaoToken(authCode);
      if (tokenResponse.statusCode == 200) {
        final accessToken = json.decode(tokenResponse.body)['access_token'];
        final userResponse = await _getKakaoUserInfo(accessToken);

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          await _handleUserProfile(userData, userData['kakao_account']['profile']['nickname'], userData['kakao_account']['email'], userData['kakao_account']['profile']['profile_image'], context);
        } else {
          _showError(context, '사용자 정보를 가져오는 데 실패했습니다: ${userResponse.body}');
        }
      } else {
        _showError(context, '액세스 토큰 요청에 실패했습니다: ${tokenResponse.body}');
      }
    } catch (error) {
      _showError(context, '카카오 로그인 중 오류가 발생했습니다: $error');
    }
  }

  /// 네이버 로그인 함수
  Future<void> signInWithNaver(BuildContext context) async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      final NaverAccessToken accessToken = result.accessToken;

      final userResponse = await http.get(
        Uri.parse('https://openapi.naver.com/v1/nid/me'),
        headers: {'Authorization': 'Bearer ${accessToken.accessToken}'},
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        await _handleUserProfile(userData, userData['response']['nickname'], userData['response']['email'], userData['response']['profile_image'], context);
      } else {
        _showError(context, '사용자 정보를 가져오는 데 실패했습니다: ${userResponse.body}');
      }
    } catch (error) {
      _showError(context, '네이버 로그인 중 오류가 발생했습니다: $error');
    }
  }

  // 사용자 프로필 처리 및 Firebase 저장
  Future<void> _handleUserProfile(firebase_auth.User? user, String? nickname, String? email, String? profileImageUrl, BuildContext context) async {
    if (user == null) return;

    String? uploadedImageUrl = await uploadProfileImage();
    await _saveUserToDatabase(user, nickname ?? '', email ?? '', uploadedImageUrl ?? profileImageUrl ?? '');
    _showSuccess(context, '로그인 성공: $nickname');
    _navigateToHome(context);
  }

  // 이미지 선택 및 업로드 함수
  Future<String?> uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String filePath = 'profile_images/${pickedFile.name}';
      FirebaseStorage storage = FirebaseStorage.instance;
      File file = File(pickedFile.path);
      await storage.ref(filePath).putFile(file);
      return await storage.ref(filePath).getDownloadURL();
    }
    return null;
  }

  // Firebase에 사용자 정보 저장 함수
  Future<void> _saveUserToDatabase(firebase_auth.User? user, String nickname, String email, String profileImage) async {
    if (user == null) return;

    final userId = user.uid;
    final userData = {
      'nickname': nickname,
      'email': email,
      'profileImage': profileImage,
      'marketingConsent': false, // 기본값 설정
    };

    DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');
    await ref.set(userData);
  }

  // 홈 화면으로 이동하는 함수
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // 성공 메시지 표시 함수
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
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

  void _handleAuthException(firebase_auth.FirebaseAuthException e, BuildContext context) {
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

  // 카카오 사용자 정보 가져오기
  Future<http.Response> _getKakaoToken(String authCode) async {
    return await http.post(
      Uri.parse('https://kauth.kakao.com/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': 'a185a267072df6495590e209e7af148b',
        'redirect_uri': 'movesmart://auth',
        'code': authCode,
      },
    );
  }

  Future<http.Response> _getKakaoUserInfo(String accessToken) async {
    return await http.get(
      Uri.parse('https://kapi.kakao.com/v2/user/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}

extension on kakao.AuthCodeClient {
  request() {}
}


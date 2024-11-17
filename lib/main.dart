import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK
import 'views/splash_screen.dart'; // SplashScreen
import 'viewmodels/splash_viewmodel.dart'; // SplashViewModel
import 'viewmodels/login_viewmodel.dart'; // LoginViewModel
import 'viewmodels/signup_viewmodel.dart'; // SignUpViewModel
import 'viewmodels/pathfinding_viewmodel.dart'; // PathfindingViewModel
import 'dart:async';

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnv();
  _initializeKakao();
  await _initializeFirebase();
  await _initializeFirebaseAppCheck();

  FirebaseAuth.instance.setLanguageCode('ko');

  runApp(const MyApp()); // 앱 실행
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: "assets/.env");
    print("Loaded .env file successfully");
  } catch (e) {
    print("Error loading .env file: $e");
  }
}

void _initializeKakao() {
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_APP_KEY'] ?? 'your_default_native_app_key',
    javaScriptAppKey: dotenv.env['KAKAO_JS_KEY'] ?? 'your_default_javascript_app_key',
  );
}

Future<void> _initializeFirebase() async {
  try {
    FirebaseApp existingApp = Firebase.app();
    print("Firebase app already initialized: ${existingApp.name}");
  } catch (e) {
    try {
      print("Initializing new Firebase app...");
      await Firebase.initializeApp(
        name: "movesmart",
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY']!,
          authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
          appId: dotenv.env['FIREBASE_APP_ID']!,
        ),
      );
      isFirebaseInitialized = true; // 초기화 완료 플래그 설정
      print("Firebase initialized successfully");
    } catch (error) {
      print("Error initializing Firebase: $error");
      showErrorDialog('Firebase 초기화 중 오류가 발생했습니다.'); // 사용자에게 알림
    }
  }
}

Future<void> _initializeFirebaseAppCheck() async {
  FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
  await firebaseAppCheck.activate(androidProvider: AndroidProvider.playIntegrity);
  print("Firebase App Check initialized successfully");
}

void showErrorDialog(String message) {
  // 오류 메시지를 보여주는 다이얼로그 구현
  print(message); // 콘솔에 오류 출력 (개발 중 사용할 수 있음)
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SignUpViewModel signUpViewModel;

  @override
  void initState() {
    super.initState();
    signUpViewModel = SignUpViewModel(); // 인스턴스화
    _handleDeepLink();
  }

  Future<void> _handleDeepLink() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      await signUpViewModel.handleEmailVerification(initialLink.link.toString());
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      if (dynamicLink != null && dynamicLink.link != null) {
        signUpViewModel.handleEmailVerification(dynamicLink.link.toString());
      }
    }, onError: (err) {
      print('링크 처리 중 오류 발생: $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => signUpViewModel),
        ChangeNotifierProvider(create: (_) => PathfindingViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(), // Splash Screen을 시작 화면으로 설정
      ),
    );
  }
}

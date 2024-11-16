import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 패키지
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 패키지 추가
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK
import 'views/splash_screen.dart'; // SplashScreen
import 'viewmodels/splash_viewmodel.dart'; // SplashViewModel
import 'viewmodels/login_viewmodel.dart'; // LoginViewModel
import 'viewmodels/signup_viewmodel.dart'; // SignUpViewModel
import 'viewmodels/pathfinding_viewmodel.dart'; // PathfindingViewModel
import 'package:uni_links3/uni_links.dart';
import 'dart:async'; // Timer 클래스를 사용하기 위한 import

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await _loadEnv();

  // Kakao 초기화
  _initializeKakao();

  // Firebase 초기화
  await _initializeFirebase();

  // Firebase App Check 초기화
  await _initializeFirebaseAppCheck();

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
    // 이미 초기화된 Firebase 앱이 있는지 확인
    FirebaseApp existingApp = Firebase.app();
    print("Firebase app already initialized: ${existingApp.name}");
  } catch (e) {
    // 초기화되지 않은 경우 새로운 Firebase 앱을 초기화
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
  }
}

Future<void> _initializeFirebaseAppCheck() async {
  FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
  //await firebaseAppCheck.activate(androidProvider: AndroidProvider.debug); // 기본 App Check 활성화
  await firebaseAppCheck.activate(androidProvider: AndroidProvider.playIntegrity);
  print("Firebase App Check initialized successfully");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<String?>? _linkSubscription; // 딥링크 스트림 구독

  @override
  void initState() {
    super.initState();
    _handleDeepLink();
  }

  Future<void> _handleDeepLink() async {
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        final uri = Uri.parse(link);
        final isEmailConfirmed = uri.queryParameters['emailConfirmed'];

        if (isEmailConfirmed == 'true') {
          // 인증 성공 시 처리
          print('이메일 인증이 완료되었습니다.');
          // 예: 홈 화면으로 이동
          // Navigator.pushNamed(context, '/home');
        } else {
          // 인증 실패 처리
          print('이메일 인증이 실패했습니다.');
          // 예: 오류 메시지 표시
          // showErrorDialog('이메일 인증에 실패했습니다.');
        }
      }
    }, onError: (err) {
      print('링크 처리 중 오류 발생: $err');
      // 사용자에게 오류 메시지 표시
      // showErrorDialog('링크 처리 중 오류가 발생했습니다.');
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel(); // 딥링크 스트림 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
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

import 'package:flutter/material.dart';
import 'package:movesmart/viewmodels/pathfinding_viewmodel.dart';
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 임포트
import 'services/firebase_options.dart'; // Firebase 설정 파일 임포트
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 전체 SDK
import 'views/splash_screen.dart'; // SplashScreen import
import 'viewmodels/splash_viewmodel.dart'; // SplashViewModel import
import 'viewmodels/login_viewmodel.dart'; // LoginViewModel import
import 'viewmodels/signup_viewmodel.dart'; // SignUpViewModel import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Kakao 초기화
  KakaoSdk.init(nativeAppKey: "@string/kakao_app_key"); // 카카오 앱 키로 초기화

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); // 앱 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()), // SplashViewModel 제공
        ChangeNotifierProvider(create: (_) => LoginViewModel()), // LoginViewModel 제공
        ChangeNotifierProvider(create: (_) => SignUpViewModel()), // SignUpViewModel 제공
        ChangeNotifierProvider(create: (_) => PathfindingViewModel()), // PathfindingViewModel 제공
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

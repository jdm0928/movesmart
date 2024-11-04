import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 임포트
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import 'services/firebase_options.dart'; // Firebase 설정 파일 임포트
import 'views/splash_screen.dart'; // SplashScreen import
import 'viewmodels/splash_viewmodel.dart'; // SplashViewModel import
import 'viewmodels/login_viewmodel.dart'; // LoginViewModel import
import 'viewmodels/signup_viewmodel.dart'; // SignUpViewModel import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter가 초기화되도록 함
  await Firebase.initializeApp( // Firebase 초기화
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

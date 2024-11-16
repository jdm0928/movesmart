import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../viewmodels/pathfinding_viewmodel.dart';

class PathfindingScreen extends StatefulWidget {
  @override
  _PathfindingScreenState createState() => _PathfindingScreenState();
}

class _PathfindingScreenState extends State<PathfindingScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    // WebViewController 초기화
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('로딩 중: $progress%');
          },
          onPageStarted: (String url) {
            print('페이지 시작: $url');
          },
          onPageFinished: (String url) {
            print('페이지 로드 완료: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('웹 리소스 오류: ${error.errorCode}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate; // 모든 요청 허용
          },
        ),
      )
      ..loadRequest(Uri.parse('https://map.kakao.com')); // 카카오맵 초기 URL 설정

    // 위치 권한 요청
    final viewModel = Provider.of<PathfindingViewModel>(context, listen: false);
    viewModel.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0), // 상단 패딩 추가
        child: WebViewWidget(controller: controller), // WebView 위젯 사용
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus, color: Colors.black),
            label: '대중교통',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation, color: Colors.black),
            label: '내비',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place, color: Colors.black),
            label: '주변(추천)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.black),
            label: '즐겨찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'MY',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.black, // 선택된 아이콘과 텍스트 색상
        unselectedItemColor: Colors.black, // 선택되지 않은 아이콘과 텍스트 색상
        showSelectedLabels: true, // 선택된 레이블 표시
        showUnselectedLabels: true, // 선택되지 않은 레이블 표시
        onTap: (index) {
          print('버튼 클릭: $index');
        },
      ),
    );
  }
}

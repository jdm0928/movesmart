import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart'; // HomeViewModel 임포트

class HomeScreen extends StatelessWidget {
  final HomeViewModel _viewModel = HomeViewModel(); // ViewModel 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // 로그아웃 아이콘
            onPressed: () async {
              await _viewModel.logout(context); // ViewModel의 로그아웃 호출
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '사용자 프로필',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '사용자 이름', // 사용자 이름을 동적으로 표시할 수 있음
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('프로필'),
              onTap: () {
                // 프로필 화면으로 이동하는 로직 추가
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {
                // 설정 화면으로 이동하는 로직 추가
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('도움말'),
              onTap: () {
                // 도움말 화면으로 이동하는 로직 추가
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.logout),
            //   title: const Text('로그아웃'),
            //   onTap: () async {
            //     await _viewModel.logout(context); // ViewModel의 로그아웃 호출
            //   },
            // ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          children: [
            _buildFeatureButton(context, '길찾기', Icons.directions_walk, () {
              _viewModel.navigateToPathfinding(context); // 길찾기 화면으로 이동
            }),
            _buildFeatureButton(context, '주행 내비', Icons.directions_car, () {
              _viewModel.navigateToNavigation(context); // 주행 내비 화면으로 이동
            }),
            _buildFeatureButton(context, '번역기', Icons.translate, () {
              _viewModel.navigateToTranslation(context); // 번역기 화면으로 이동
            }),
            _buildFeatureButton(context, '날씨 예보', Icons.wb_sunny, () {
              _viewModel.navigateToWeather(context); // 날씨 예보 화면으로 이동
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

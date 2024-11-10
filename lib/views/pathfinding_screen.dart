import 'package:flutter/material.dart';

class PathfindingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('길찾기'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 이전 화면으로 돌아가기
          },
        ),
      ),
      body: Center(
        child: Text('길찾기 기능이 구현됩니다.'),
      ),
    );
  }
}

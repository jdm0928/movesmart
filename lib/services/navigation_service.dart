import 'package:flutter/material.dart';

class NavigationService {
  // 네비게이션을 위한 메서드
  void navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

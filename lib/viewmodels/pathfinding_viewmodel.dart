import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PathfindingViewModel extends ChangeNotifier {
  String searchQuery = '';
  Position? currentPosition; // 현재 위치를 저장할 변수

  // 검색 쿼리를 업데이트하는 메서드
  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  // 카카오맵의 초기 설정 메서드
  void initializeMap() {
    // 카카오맵 초기화 관련 코드 작성 예정
  }

  // 현재 위치를 가져오는 메서드
  Future<void> getCurrentLocation() async {
    // 위치 권한 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한이 거부된 경우 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 여전히 거부된다면 오류 처리
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    // 위치 권한이 허용된 경우 현재 위치 가져오기
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    notifyListeners(); // 위치 정보 변경 알림
    print('현재 위치: ${currentPosition?.latitude}, ${currentPosition?.longitude}');
  }
}

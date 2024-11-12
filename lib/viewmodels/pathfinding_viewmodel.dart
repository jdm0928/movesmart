import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class PathfindingViewModel extends ChangeNotifier {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng currentLocation = LatLng(37.5665, 126.978); // 초기 위치 (서울)
  double zoomLevel = 15.0; // 초기 줌 레벨

  PathfindingViewModel() {
    _getCurrentLocation(); // 생성자에서 현재 위치를 가져옴
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 권한 요청
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      print(e); // 에러 로그
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  void addMarker(LatLng position) {
    // 기존 마커가 있으면 제거
    if (markers.isNotEmpty) {
      markers.clear(); // 모든 마커를 지움
    }

    // 새로운 마커 추가
    markers.add(Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(title: 'Selected Location'),
    ));

    // 카메라 위치와 줌 레벨 설정
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: zoomLevel,
      ),
    ));

    notifyListeners(); // 상태 변경 통지
  }

  void setZoomLevel(double level) {
    zoomLevel = level;
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation,
          zoom: zoomLevel,
        ),
      ));
    }
    notifyListeners(); // 상태 변경 통지
  }

  void clearMarkers() {
    markers.clear();
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/pathfinding_viewmodel.dart';

class PathfindingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PathfindingViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pathfinding'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
          ),
        ),
        body: Consumer<PathfindingViewModel>(
          builder: (context, viewModel, child) {
            return GoogleMap(
              onMapCreated: viewModel.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: viewModel.currentLocation,
                zoom: viewModel.zoomLevel,
              ),
              markers: viewModel.markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (position) {
                viewModel.addMarker(position); // 맵을 클릭할 때 마커 추가
              },
            );
          },
        ),
      ),
    );
  }
}

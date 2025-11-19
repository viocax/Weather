import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? cityName;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.cityName,
  });
}

// 抽象介面，方便測試時 mock
abstract class GeolocatorWrapper {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position> getCurrentPosition();
}

// 實際實作
class GeolocatorWrapperImpl implements GeolocatorWrapper {
  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  @override
  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}

class LocationService {
  final GeolocatorWrapper _geolocator;

  LocationService({GeolocatorWrapper? geolocator})
      : _geolocator = geolocator ?? GeolocatorWrapperImpl();

  // 取得當前位置
  Future<LocationData?> getCurrentLocation() async {
    try {
      // 檢查定位服務是否開啟
      bool serviceEnabled = await _geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('定位服務未開啟');
        return null;
      }

      // 檢查並請求權限
      LocationPermission permission = await _geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('定位權限被拒絕');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('定位權限被永久拒絕');
        return null;
      } 

      // 取得當前位置
      Position position = await _geolocator.getCurrentPosition();

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('取得定位失敗: $e');
      return null;
    }
  }

  // 檢查定位權限
  Future<bool> checkPermission() async {
    LocationPermission permission = await _geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // 請求定位權限
  Future<bool> requestPermission() async {
    LocationPermission permission = await _geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // 檢查定位服務是否開啟
  Future<bool> isLocationServiceEnabled() async {
    return await _geolocator.isLocationServiceEnabled();
  }
}

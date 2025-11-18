import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather/data/service/location_service.dart';

import 'location_service_test.mocks.dart';

@GenerateMocks([GeolocatorWrapper])
void main() {
  late LocationService locationService;
  late MockGeolocatorWrapper mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocatorWrapper();
    locationService = LocationService(geolocator: mockGeolocator);
  });

  group('getCurrentLocation', () {
    test('應該成功回傳位置資料', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockGeolocator.getCurrentPosition()).thenAnswer(
        (_) async => Position(
          latitude: 25.0330,
          longitude: 121.5654,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      );

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, isNotNull);
      expect(result!.latitude, 25.0330);
      expect(result.longitude, 121.5654);
    });

    test('定位服務未開啟時應該回傳 null', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, isNull);
    });

    test('權限被拒絕時應該回傳 null', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, isNull);
    });

    test('權限被永久拒絕時應該回傳 null', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, isNull);
    });

    test('請求權限後成功取得位置', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockGeolocator.getCurrentPosition()).thenAnswer(
        (_) async => Position(
          latitude: 25.0330,
          longitude: 121.5654,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      );

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, isNotNull);
      expect(result!.latitude, 25.0330);
    });

    test('發生例外時應該回傳 null', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenThrow(Exception('測試錯誤'));

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, isNull);
    });
  });

  group('checkPermission', () {
    test('有 whileInUse 權限時應該回傳 true', () async {
      // Arrange
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      // Act
      final result = await locationService.checkPermission();

      // Assert
      expect(result, true);
    });

    test('有 always 權限時應該回傳 true', () async {
      // Arrange
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);

      // Act
      final result = await locationService.checkPermission();

      // Assert
      expect(result, true);
    });

    test('權限被拒絕時應該回傳 false', () async {
      // Arrange
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      // Act
      final result = await locationService.checkPermission();

      // Assert
      expect(result, false);
    });
  });

  group('isLocationServiceEnabled', () {
    test('定位服務開啟時應該回傳 true', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);

      // Act
      final result = await locationService.isLocationServiceEnabled();

      // Assert
      expect(result, true);
    });

    test('定位服務關閉時應該回傳 false', () async {
      // Arrange
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      // Act
      final result = await locationService.isLocationServiceEnabled();

      // Assert
      expect(result, false);
    });
  });
}

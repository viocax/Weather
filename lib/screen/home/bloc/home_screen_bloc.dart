import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/screen/home/bloc/home_screen_event.dart';
import 'package:weather/screen/home/bloc/home_screen_state.dart';
import 'package:weather/data/service/location_service.dart';
import 'package:weather/services/settings_service.dart';
import 'package:weather/data/request/get_weather_request.dart';
import 'package:weather/data/request/get_hourly_forecast_request.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final LocationService _locationService;
  final SettingsService _settingsService;

  HomeScreenBloc({
    LocationService? locationService,
    SettingsService? settingsService,
  }) : _locationService = locationService ?? LocationService(),
       _settingsService = settingsService ?? SettingsService(),
       super(const HomeScreenLoadingState()) {
    on<GetHomeScreenDataEvent>(_onGetHomeScreenData);
    on<HomeScreenErrorRetryEvent>(_onErrorRetry);
  }

  Future<void> _onGetHomeScreenData(
    GetHomeScreenDataEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      // 發射載入中狀態
      emit(const HomeScreenLoadingState());

      // 載入設定
      final settings = await _settingsService.loadSettings();

      // 取得當前位置
      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        emit(const HomeScreenErrorState('無法取得位置資訊'));
        return;
      }

      // 取得天氣資料
      final getCurrentWeather = GetWeatherRequest(
        lat: location.latitude,
        lon: location.longitude,
      );
      final getForecast = GetForecastRequest(
        lat: location.latitude,
        lon: location.longitude,
      );
      final weatherResponse = await getCurrentWeather.request();
      final forecastResponse = await getForecast.request();

      // 檢查 API 回應
      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        emit(
          HomeScreenLoadedState(
            currentWeather: weatherResponse.model,
            hourlyForecast: forecastResponse.model.hourly,
            dailyForecast: forecastResponse.model.daily,
            settings: settings,
          ),
        );
      } else {
        emit(
          HomeScreenErrorState(
            'API 錯誤: Weather ${weatherResponse.statusCode}, Forecast ${forecastResponse.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(HomeScreenErrorState('取得天氣資料失敗: $e'));
    }
  }

  Future<void> _onErrorRetry(
    HomeScreenErrorRetryEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    // 重試時重新載入資料
    add(const GetHomeScreenDataEvent());
  }
}

import 'package:equatable/equatable.dart';

abstract class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  @override
  List<Object?> get props => [];
}

class GetHomeScreenDataEvent extends HomeScreenEvent {
  const GetHomeScreenDataEvent();
}

class HomeScreenErrorRetryEvent extends HomeScreenEvent {
  const HomeScreenErrorRetryEvent();
}

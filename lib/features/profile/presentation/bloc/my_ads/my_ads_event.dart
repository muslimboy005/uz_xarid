part of 'my_ads_bloc.dart';

abstract class MyAdsEvent extends Equatable {
  const MyAdsEvent();

  @override
  List<Object?> get props => [];
}

class MyAdsLoadRequested extends MyAdsEvent {
  const MyAdsLoadRequested(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

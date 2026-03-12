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

class MyAdsDeleteRequested extends MyAdsEvent {
  const MyAdsDeleteRequested(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}

import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/profile/data/model/viewed_ads_response_model.dart';

enum ViewHistoryStatus { initial, loading, success, failure }

class ViewHistoryState extends Equatable {
  final ViewHistoryStatus status;
  final ViewedAdsResponseModel? history;
  final String? errorMessage;

  const ViewHistoryState({
    this.status = ViewHistoryStatus.initial,
    this.history,
    this.errorMessage,
  });

  ViewHistoryState copyWith({
    ViewHistoryStatus? status,
    ViewedAdsResponseModel? history,
    String? errorMessage,
  }) {
    return ViewHistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, history, errorMessage];
}

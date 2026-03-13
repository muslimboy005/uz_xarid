import 'package:equatable/equatable.dart';

abstract class ViewHistoryEvent extends Equatable {
  const ViewHistoryEvent();

  @override
  List<Object> get props => [];
}

class GetViewHistoryEvent extends ViewHistoryEvent {
  final int page;
  final int pageSize;

  const GetViewHistoryEvent({this.page = 1, this.pageSize = 20});

  @override
  List<Object> get props => [page, pageSize];
}

class ClearHistoryEvent extends ViewHistoryEvent {
  const ClearHistoryEvent();

  @override
  List<Object> get props => [];
}

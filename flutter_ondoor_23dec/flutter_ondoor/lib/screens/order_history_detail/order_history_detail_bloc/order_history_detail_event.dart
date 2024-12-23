import 'package:equatable/equatable.dart';
import '../../../models/order_history_detail_response.dart';

class OrderHistoryDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderHistoryDetailInitialEvent extends OrderHistoryDetailEvent {
  @override
  List<Object?> get props => [];
}

class OrderHistoryDetailLoadingEvent extends OrderHistoryDetailEvent {
  @override
  List<Object?> get props => [];
}

class OrderHistoryDetailLoadedEvent extends OrderHistoryDetailEvent {
  OrderHistoryDetailData orderHistoryData;
  @override
  List<Object?> get props => [orderHistoryData];
  OrderHistoryDetailLoadedEvent({required this.orderHistoryData});
}

class OrderHistoryDetailNullEvent extends OrderHistoryDetailEvent {
  @override
  List<Object?> get props => [];
  OrderHistoryDetailNullEvent();
}

class ErrorEvent extends OrderHistoryDetailEvent {
  String errorMessage;
  @override
  List<Object?> get props => [errorMessage];
  ErrorEvent({required this.errorMessage});
}

class OrderHistoryDetailTabChangeEvent extends OrderHistoryDetailEvent {
  int tabIndex;
  OrderHistoryDetailTabChangeEvent({required this.tabIndex});
  @override
  List<Object?> get props => [tabIndex];
}

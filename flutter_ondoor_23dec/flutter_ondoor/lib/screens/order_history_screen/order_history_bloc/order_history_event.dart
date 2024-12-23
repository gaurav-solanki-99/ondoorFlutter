import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_order_history_response.dart';

class OrderHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderHistoryInitialEvent extends OrderHistoryEvent {
  @override
  List<Object?> get props => [];
}

class OrderHistoryLoadingEvent extends OrderHistoryEvent {
  @override
  List<Object?> get props => [];
}

class OrderHistoryErrorEvent extends OrderHistoryEvent {
  String errorString;
  OrderHistoryErrorEvent({required this.errorString});
  @override
  List<Object?> get props => [errorString];
}

class OrderHistoryLoadedEvent extends OrderHistoryEvent {
  List<OrderHistoryData> orderHistoryList = [];
  OrderHistoryLoadedEvent({required this.orderHistoryList});
  @override
  List<Object?> get props => [orderHistoryList];
}
class OrderHistoryImageArrayEvent extends OrderHistoryEvent {
  List<OrderHistoryData> orderHistoryList = [];
  OrderHistoryImageArrayEvent({required this.orderHistoryList});
  @override
  List<Object?> get props => [orderHistoryList];
}

class RateUsTappedEvent extends OrderHistoryEvent {
  OrderHistoryData orderHistoryData;
  RateUsTappedEvent({required this.orderHistoryData});
  @override
  List<Object?> get props => [orderHistoryData];
}

class DurationChangeEvent extends OrderHistoryEvent {
  String selectedDurationName;
  String selectedarchiveId;
  DurationChangeEvent(
      {required this.selectedDurationName, required this.selectedarchiveId});
  @override
  List<Object?> get props => [selectedDurationName, selectedarchiveId];
}

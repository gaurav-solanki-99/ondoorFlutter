import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_order_history_response.dart';

class OrderHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderHistoryInitialState extends OrderHistoryState {
  @override
  List<Object?> get props => [];
}

class OrderHistoryLoadingState extends OrderHistoryState {
  @override
  List<Object?> get props => [];
}

class OrderHistoryLoadedState extends OrderHistoryState {
  List<OrderHistoryData> orderHistoryList = [];
  OrderHistoryLoadedState({required this.orderHistoryList});
  @override
  List<Object?> get props => [orderHistoryList];
}

class OrderHistoryImageArrayState extends OrderHistoryState {
  List<OrderHistoryData> orderHistoryList = [];
  OrderHistoryImageArrayState({required this.orderHistoryList});
  @override
  List<Object?> get props => [orderHistoryList];
}

class RateUsTappedState extends OrderHistoryState {
  OrderHistoryData orderHistoryData;
  RateUsTappedState({required this.orderHistoryData});
  @override
  List<Object?> get props => [orderHistoryData];
}

class OrderHistoryErrorState extends OrderHistoryState {
  String errorString;
  OrderHistoryErrorState({required this.errorString});
  @override
  List<Object?> get props => [errorString];
}

class DurationChangeState extends OrderHistoryState {
  String selectedDurationName;
  String selectedarchiveId;
  DurationChangeState(
      {required this.selectedDurationName, required this.selectedarchiveId});
  @override
  List<Object?> get props => [selectedDurationName, selectedarchiveId];
}

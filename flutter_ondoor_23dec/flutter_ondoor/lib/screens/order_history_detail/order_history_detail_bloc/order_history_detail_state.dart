import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_order_history_response.dart';

import '../../../models/order_history_detail_response.dart';

class OrderHistoryDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderHistoryDetailInitialState extends OrderHistoryDetailState {
  @override
  List<Object?> get props => [];
}

class OrderHistoryDetailLoadingState extends OrderHistoryDetailState {
  @override
  List<Object?> get props => [];
}

class OrderHistoryDetailNullState extends OrderHistoryDetailState {
  @override
  List<Object?> get props => [];
  OrderHistoryDetailNullState();
}

class OrderHistoryDetailLoadedState extends OrderHistoryDetailState {
  OrderHistoryDetailData orderHistoryData;
  @override
  List<Object?> get props => [orderHistoryData];
  OrderHistoryDetailLoadedState({required this.orderHistoryData});
}

class ErrorState extends OrderHistoryDetailState {
  String errorMessage;
  @override
  List<Object?> get props => [errorMessage];
  ErrorState({required this.errorMessage});
}

class OrderHistoryDetailTabChangeState extends OrderHistoryDetailState {
  int tabIndex;
  OrderHistoryDetailTabChangeState({required this.tabIndex});
  @override
  List<Object?> get props => [tabIndex];
}

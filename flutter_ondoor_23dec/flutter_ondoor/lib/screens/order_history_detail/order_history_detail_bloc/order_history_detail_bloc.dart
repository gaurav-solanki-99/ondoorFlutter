import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/models/order_history_detail_response.dart';
import 'package:ondoor/screens/order_history_detail/order_history_detail_bloc/order_history_detail_event.dart';
import 'package:ondoor/screens/order_history_detail/order_history_detail_bloc/order_history_detail_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

class OrderHistoryDetailBloc
    extends Bloc<OrderHistoryDetailEvent, OrderHistoryDetailState> {
  OrderHistoryDetailBloc() : super(OrderHistoryDetailInitialState()) {
    on<OrderHistoryDetailInitialEvent>(
      (event, emit) {
        emit(OrderHistoryDetailInitialState());
      },
    );
    on<OrderHistoryDetailNullEvent>(
      (event, emit) {
        emit(OrderHistoryDetailNullState());
      },
    );
    on<OrderHistoryDetailLoadingEvent>(
      (event, emit) {
        emit(OrderHistoryDetailLoadingState());
      },
    );
    on<OrderHistoryDetailLoadedEvent>(
      (event, emit) {
        emit(OrderHistoryDetailLoadedState(
            orderHistoryData: event.orderHistoryData));
      },
    );
    on<ErrorEvent>(
      (event, emit) {
        emit(ErrorState(errorMessage: event.errorMessage));
      },
    );
    on<OrderHistoryDetailTabChangeEvent>(
      (event, emit) {
        emit(OrderHistoryDetailTabChangeState(tabIndex: event.tabIndex));
      },
    );
  }
  void getOrderbyOrderId(context, String order_ID, String order_type) async {
    if (await Network.isConnected()) {
      add(OrderHistoryDetailLoadingEvent());
      OrderHistoryDetailResponse orderHistoryDetailResponse =
          await ApiProvider().getOrderHistoryDetail(order_ID, order_type, () {
        getOrderbyOrderId(context, order_ID, order_type);
      });
      if (orderHistoryDetailResponse.success == true) {
        add(OrderHistoryDetailLoadedEvent(
            orderHistoryData: orderHistoryDetailResponse.data!));
      } else {
        add(ErrorEvent(errorMessage: "Something Went Wrong!!"));
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getOrderbyOrderId(context, order_ID, order_type);
      });
    }
  }
}

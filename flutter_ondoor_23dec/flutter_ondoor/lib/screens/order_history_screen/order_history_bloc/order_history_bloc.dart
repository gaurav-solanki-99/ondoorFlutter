import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/models/get_order_history_response.dart';
import 'package:ondoor/screens/order_history_screen/order_history_bloc/order_history_event.dart';
import 'package:ondoor/screens/order_history_screen/order_history_bloc/order_history_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/NetworkConfig.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

import '../../../constants/StringConstats.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  List<OrderHistoryData> orderHistoryList = [];
  OrderHistoryBloc() : super(OrderHistoryInitialState()) {
    on<OrderHistoryInitialEvent>(
        (event, emit) => emit(OrderHistoryInitialState()));
    on<OrderHistoryLoadingEvent>(
        (event, emit) => emit(OrderHistoryLoadingState()));
    on<OrderHistoryLoadedEvent>(
      (event, emit) {
        emit(OrderHistoryLoadingState());
        emit(OrderHistoryLoadedState(orderHistoryList: event.orderHistoryList));
      },
    );
    on<OrderHistoryImageArrayEvent>(
      (event, emit) {
        emit(OrderHistoryLoadingState());
        emit(OrderHistoryImageArrayState(
            orderHistoryList: event.orderHistoryList));
      },
    );
    on<RateUsTappedEvent>(
      (event, emit) {
        emit(OrderHistoryLoadingState());
        emit(RateUsTappedState(orderHistoryData: event.orderHistoryData));
      },
    );
    on<OrderHistoryErrorEvent>(
      (event, emit) {
        emit(OrderHistoryLoadingState());
        emit(OrderHistoryErrorState(errorString: event.errorString));
      },
    );
    on<DurationChangeEvent>(
      (event, emit) {
        emit(OrderHistoryLoadingState());
        emit(DurationChangeState(
            selectedDurationName: event.selectedDurationName,
            selectedarchiveId: event.selectedarchiveId));
      },
    );
  }

  void getOrderHistory(context, String archiveId) async {
    if (await Network.isConnected()) {
      add(OrderHistoryLoadingEvent());
      String customerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String tokenType =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String accessToken =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      String locationId =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String token = "$tokenType $accessToken";

      try {
        GetOrderHistoryResponse orderHistoryResponse = await ApiProvider()
            .getOrderHistory(archiveId, customerId, token, locationId, () {
          getOrderHistory(context, archiveId);
        });
        print("ORDERHISTORY RESPONSE ${orderHistoryResponse.success}");

        if (orderHistoryResponse.success == true) {
          print("ORDERHISTORY RESPONSE ${orderHistoryResponse.error}");
          print("ORDERHISTORY RESPONSE ${orderHistoryResponse.data!.length}");
          // Use orderHistoryResponse.data for further processing
          add(OrderHistoryLoadedEvent(
              orderHistoryList: orderHistoryResponse.data ?? []));
        } else {
          // Handle error scenario
          print("Error: ${orderHistoryResponse.error}");
          add(OrderHistoryLoadedEvent(orderHistoryList: []));
          add(OrderHistoryErrorEvent(errorString: orderHistoryResponse.error!));
        }
      } catch (exception, stackTrace) {
        print("EXCEPTION ${exception}");
        print("EXCEPTION STACKTRACE $stackTrace");
        add(OrderHistoryLoadedEvent(orderHistoryList: []));
        add(OrderHistoryErrorEvent(errorString: exception.toString()));
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getOrderHistory(context, archiveId);
      });
    }
  }
}

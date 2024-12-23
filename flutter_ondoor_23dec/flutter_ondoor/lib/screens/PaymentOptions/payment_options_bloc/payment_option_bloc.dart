import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/screens/PaymentOptions/payment_options_bloc/payment_option_event.dart';
import 'package:ondoor/screens/PaymentOptions/payment_options_bloc/payment_option_state.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:path/path.dart';

import '../../../constants/Constant.dart';
import '../../../models/paytm_checksum_response.dart';
import '../../../services/ApiServices.dart';
import '../../../services/Navigation/routes.dart';
import '../../../utils/Connection.dart';
import '../../../utils/colors.dart';
import '../../../utils/sharedpref.dart';
import '../../../widgets/AppWidgets.dart';
import '../Payment_Integreation.dart';

class PaymentOptionBloc extends Bloc<PaymentOptionEvent, PaymentOptionState> {
  PaymentOptionBloc() : super(PaymentOptionInitialState()) {
    on<PaymentOptionInitialEvent>(
      (event, emit) {
        emit(PaymentOptionInitialState());
      },
    );
    on<PaymentOptionNullEvent>(
      (event, emit) {
        emit(PaymentOptionNullState());
      },
    );
    on<PaymentOptionAnimationEvent>(
      (event, emit) {
        emit(PaymentOptionNullState());
        emit(PaymentOptionAnimationState(
            shrinkAnimation: event.shrinkAnimation));
      },
    );
    on<PaymentStatusEvent>(
      (event, emit) {
        emit(PaymentStatusState(
            saveOrdertoDatabaseResponse: event.saveOrdertoDatabaseResponse));
      },
    );
    on<PaymentOptionSelectedEvent>(
      (event, emit) {
        emit(PaymentOptionSelectedState(
            selectedPaymentGateway: event.selectedPaymentGateway));
      },
    );
    on<PaymentOptionAddressChangeEvent>(
      (event, emit) {
        emit(PaymentOptionAddressChangeState(
            selectedAddressData: event.selectedAddressData));
      },
    );
    on<PaymentOptionFailureEvent>(
      (event, emit) {
        emit(PaymentOptionFailureState(
            saveOrdertoDatabaseResponse: event.saveOrdertoDatabaseResponse));
      },
    );
    on<InitilizedPaytmPaymentEvent>(initilizedpaytm);
    on<PaymentOptionSuccessEvent>(paymentSuccessEvent);
  }
  FutureOr initilizedpaytm(InitilizedPaytmPaymentEvent event,
      Emitter<PaymentOptionState> emit) async {
    if (await Network.isConnected()) {
      Map<String, dynamic> params = {};
      debugPrint("ORDER ID CHECKSUME ${event.resjsondata.orderId}");
      try {
        params['order_id'] = event.resjsondata.orderId;
        params['customer_id'] =
            await SharedPref.getStringPreference(Constants.sp_CustomerId);
        // params['amount'] = "1.00";
        params['amount'] = event.resjsondata.total.toString();
        // params['paytm_type'] = "Paytm";
      } catch (error, stackTrace) {
        debugPrint("$error $stackTrace"); // Prints the error stack trace
      }
      String jsonString = json.encode(params);

      try {
        PaytmChecksumresponse result =
            await ApiProvider().getValidateCheckSum(jsonString, () {
          initilizedpaytm(event, emit);
        });
        log("i am here: res ${jsonEncode(result)}");
        if (jsonString.isNotEmpty) {
          if (result.success == true) {
            UpiPaymentIntegration()
                .payment(result.mid, result.orderId, result.amount,
                    result.txnToken, result.callbackUrl, false)
                .then((value) async {
              Map<String, dynamic> checkinput = HashMap();
              checkinput['Resp_code'] = value!['RESPCODE'];
              print("Transaction Response ${value}");
              if (value != null && value["STATUS"] == "TXN_SUCCESS") {
                print("Transaction Response ${value}");
                add(PaymentOptionSuccessEvent(
                    resjsondata: event.resjsondata,
                    checksumResponse: result,
                    paytmData: value,
                    selectedTimeSlot: event.selectedTimeSlot,
                    selectedDateSlot: event.selectedTimeSlot,
                    finalAddress: event.finalAddress,
                    callbackUrl: result.callbackUrl!,
                    context: event.context));
                // check apyment event
                // buyTicketFormBloc
                //     .add(CheckPaymentStatusTkTServerEvent(input: checkinput));
              } else {
                MyDialogs.showAlertDialogNew(
                    event.context, "Transaction Failed", "Okay", "", () {
                  Navigator.pop(event.context);
                }, () {
                  Navigator.pop(event.context);
                });
              }
            }).onError(
              (error, stackTrace) {
                debugPrint("payment integration ${error}");
                debugPrint("payment ${stackTrace}");
                MyDialogs.showAlertDialogNew(
                    event.context, "Transaction Failed", "Okay", "", () {
                  Navigator.pop(event.context);
                }, () {
                  Navigator.pop(event.context);
                });
              },
            ).catchError((e, stack) {
              debugPrint("payment integration ${e}");
              debugPrint("payment ${stack}");
              MyDialogs.showAlertDialogNew(
                  event.context, "Transaction Failed", "Okay", "", () {
                Navigator.pop(event.context);
              }, () {
                Navigator.pop(event.context);
              });
            });
          } else {
            Appwidgets.showToastMessage("Something Went Wrong !!");
          }
        } else {
          log("i am here: resULT ${result}");
        }
      } catch (error, stackTrace) {
        debugPrint("ERROR ${error}");
        debugPrint("STACKTRACE ${stackTrace}");
      }
    } else {
      MyDialogs.showInternetDialog(
          navigationService.navigatorKey.currentContext!, () {
        Navigator.pop(navigationService.navigatorKey.currentContext!);
      });
    }
  }

  FutureOr paymentSuccessEvent(
      PaymentOptionSuccessEvent event, Emitter<PaymentOptionState> emit) async {
    if (await Network.isConnected()) {
/*      log("paytm Data ${event.paytmData}");
      log("checksum response ${event.checksumResponse.toJson()}");
      Dio dio = Dio();

      var data = {
        "ORDERID": event.checksumResponse.orderId,
        "MID": event.checksumResponse.mid,
        "CHECKSUMHASH": event.checksumResponse.checksumhash,
        "TXNAMOUNT": event.checksumResponse.amount,
        "RESPCODE": event.paytmData['RESPCODE'],
        "RESPMSG": event.paytmData['RESPMSG'],
        "TXNID": event.paytmData['TXNID'],
        "PAYMENTMODE": event.paytmData['PAYMENTMODE'],
        "GATEWAYNAME": event.paytmData['GATEWAYNAME'],
        "STATUS": event.paytmData['STATUS'],
        "TXNDATE": event.paytmData['TXNDATE']
      };
      Response response = await dio.post(event.callbackUrl, data: data);*/
      // if (response.statusCode == 200) {
      //
      // } else {}
      checkonlinePayment(event);
    } else {
      MyDialogs.showInternetDialog(
          navigationService.navigatorKey.currentContext!, () {});
    }
  }

  checkonlinePayment(event) {
    ApiProvider().checkOnlinePayment(event.resjsondata.orderId.toString(), () {
      checkonlinePayment(event);
    }).then(
      (value) {
        log("checkonlinepayment response ${value.toJson()}");
        if (value.success == true) {
          Navigator.pushNamed(event.context, Routes.order_status_screen,
              arguments: {
                "success": true,
                "message": event.resjsondata.message,
                "order_id": event.resjsondata.orderId ?? 0,
                "amount": event.resjsondata.total,
                "paid_by": "Paytm",
                "coupon_id": event.resjsondata.coupon ?? "",
                "rating_redirect_url":
                    event.resjsondata.ratings!.ratingRiderctUrl ?? "",
                "delivery_location": event.finalAddress,
                "selected_time_slot": event.selectedTimeSlot,
                "selected_date_slot": event.selectedDateSlot,
              }).then(
            (value) {
              Appwidgets.setStatusBarDynamicDarkColor(
                  color: ColorName.sugarCane);
            },
          );
        } else {
          Appwidgets.showToastMessage(value.message!);
        }
      },
    );
  }
}

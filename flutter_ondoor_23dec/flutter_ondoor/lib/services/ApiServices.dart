import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/models/GetTimeSlotsResponse.dart';
import 'package:ondoor/models/add_notification_response.dart';
import 'package:ondoor/models/add_shopping_list_response.dart';
import 'package:ondoor/models/CartJsonModel.dart';
import 'package:ondoor/models/address_list_response.dart';
import 'package:ondoor/models/address_response.dart';
import 'package:ondoor/models/cancel_order_response.dart';
import 'package:ondoor/models/change_delivery_slot_response.dart';
import 'package:ondoor/models/contact_us_reason_list_response.dart';
import 'package:ondoor/models/contact_us_response.dart';
import 'package:ondoor/models/delete_address_response.dart';
import 'package:ondoor/models/get_city_response.dart';
import 'package:ondoor/models/get_filter_response.dart';
import 'package:ondoor/models/get_latest_order_response.dart';
import 'package:ondoor/models/get_order_history_response.dart';
import 'package:ondoor/models/get_page_response.dart';
import 'package:ondoor/models/get_profile_response.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';
import 'package:ondoor/models/notification_list_response.dart';
import 'package:ondoor/models/order_history_detail_response.dart';
import 'package:ondoor/models/order_on_phone_response.dart';
import 'package:ondoor/models/save_order_to_database_response.dart';
import 'package:ondoor/models/shopping_list_modification_response.dart';
import 'package:ondoor/models/time_slot_response.dart';
import 'package:ondoor/services/NetworkConfig.dart';
import 'package:ondoor/services/server_error.dart';
import 'package:ondoor/services/Endpoints.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../models/AllProducts.dart';
import '../models/CheckSumResponse.dart';
import '../models/Credit_request_model.dart';
import '../models/HomepageModel.dart';

import '../models/ShippingCharges.dart';
import '../models/VerifyModel.dart';
import '../models/check_credit_without_login_response.dart';
import '../models/check_online_payment_response.dart';
import '../models/edit_order_response.dart';
import '../models/filter_data_params.dart';
import '../models/get_coco_code_response.dart';
import '../models/order_by_order_id_response.dart';
import '../models/paytm_checksum_response.dart';
import '../models/product_validation_response.dart';
import '../models/register_response.dart';
import '../models/reward_summary_response.dart';
import '../models/save_order_to_database_params.dart';
import '../models/shop_by_category_response.dart';
import '../models/validate_app_version_response.dart';
import '../utils/Utility.dart';
import '../utils/sharedpref.dart';
import 'Navigation/routes.dart';

class ApiProvider {
  static final ApiProvider _apiprovider = ApiProvider._internal();
  CancelToken cancelToken = CancelToken();

  late Dio _dio;

  factory ApiProvider() {
    return _apiprovider;
  }

  ApiProvider._internal() {
    initializeDio();
  }

  Future<void> initializeDio() async {
    _dio = await DioFactory().getDio();
    // _dio.options.headers = {
    //   'Connection': 'keep-alive',
    // };
  }

  Future<ValidateAppVersionResponse> validateAppVersionApi() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      debugPrint("package version ${packageInfo.version}");
      // Response response = await _dio.get("${Endpoints.validateApp}${packageInfo.version}",
      Response response = await _dio.get(
          "${Endpoints.validateApp}${packageInfo.version}",
          cancelToken: cancelToken);

      ValidateAppVersionResponse validateAppVersionResponse =
          ValidateAppVersionResponse.fromJson(response.data.toString());

      return validateAppVersionResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        //ServerError? e = ServerError.withError(error: error);
        message = error.message!;
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      cancelToken.cancel('Logged out');
      cancelToken = CancelToken();
      return ValidateAppVersionResponse(
          success: "Error $message",
          cityList: [],
          creditprogram: 0,
          currentLocationTxt: "",
          currentlyServedCityTxt: "",
          currentlyServedTxt: "",
          deliveryLocationSearchHint: "",
          locationHeaderTxt: "",
          noOfRecentItems: "",
          recentAddress: "",
          savedAddress: "",
          setDeliveryLocationHeaderTxt: "",
          showLocationRetryMessage: "");
    }
  }

  Future<ProductsModel> reOrderAPI(String order_ID, Function callback) async {
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String token = "$token_type $access_token";
    var headers = {
      "Authorization": token,
      "ondoor_app_code": Endpoints.AppVersionCode,
      "wmsstoreid": wms_store_id,
      "storename": store_name,
      "device_type": Platform.isAndroid ? "android" : "ios",
      "customer_id": coustomerId,
      "storeid": store_id,
      "location_id": location_id,
      "storecode": store_code
    };

    try {
      var data = {"customer_id": coustomerId, "order_id": order_ID};
      Response response = await _dio.post(Endpoints.reorder,
          data: data,
          options: Options(headers: headers, preserveHeaderCase: true),
          cancelToken: cancelToken);
      ProductsModel reOrderResponse = ProductsModel();
      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        return ProductsModel(success: false);
      } else {
        reOrderResponse = ProductsModel.fromJson(response.data.toString());
      }

      return reOrderResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ProductsModel(success: false);
    }
  }

  Future<HomePageModel> getNewCategory(Map input) async {
    try {
      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      Response response = await _dio.post(Endpoints.getNewCategory,
          options: Options(
            headers: {
              'location_id':
                  '$location_id', // Replace 'your_value_here' with your actual value
            },
          ),
          cancelToken: cancelToken);
      HomePageModel loginResponse = HomePageModel.fromJson(response.toString());
      return loginResponse;
    } catch (error, stacktrace) {
      String message = "Something Went wrong";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      // Utility.showToast(message);
      return HomePageModel(
        success: false,
        categories: [],
        banners: [],
        footer: [],
      );
    }
  }

  Future<EditOrderResponse> editOrderResponse(body, Function callback) async {
    try {
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      Response response = await _dio.post(Endpoints.editOrderByCustomer,
          data: body,
          cancelToken: cancelToken,
          options: Options(
              headers: {"Authorization": token}, preserveHeaderCase: true));
      if (response.statusCode == 200) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        if (response.toString().contains("statusText") &&
            token.trim().isNotEmpty) {
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
          return EditOrderResponse(
            success: false,
            message: "",
            orderId: "",
          );
        } else {
          EditOrderResponse editOrderResponse =
              EditOrderResponse.fromJson(response.data);
          return editOrderResponse;
        }
      } else {
        return EditOrderResponse(
            success: false, message: response.statusMessage);
      }
    } catch (exception, stackTrace) {
      print("Edit Order Exception ${exception}");
      print("Edit Order trace ${stackTrace}");
      String message = "";
      if (exception is DioException) {
        ServerError e = ServerError.withError(error: exception);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stackTrace");
      return EditOrderResponse(success: false, message: message);
    }
  }

  Future<ShoppingListModificationResponse> renameShoppingList(
      String renameText, String shoppingListID) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var data = {
        "customer_id": coustomerId,
        "name": renameText,
        "shopping_list_id": shoppingListID
      };
      var headers = {"Authorization": token};
      Response response = await _dio.post(Endpoints.renameShoppingList,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(navigationService.navigatorKey.currentContext!, () {});
        }
        return ShoppingListModificationResponse(success: false, message: "");
      }
      ShoppingListModificationResponse shoppingListModificationResponse =
          ShoppingListModificationResponse.fromJson(response.data.toString());
      return shoppingListModificationResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ShoppingListModificationResponse();
    }
  }

  Future<AddNotificationResponse> addNotiFication(Function callback) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      debugPrint("package version ${packageInfo.version}");

      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String fcm_token =
          await SharedPref.getStringPreference(Constants.fcmToken);

      String token = "$token_type $access_token";
      var data = {
        "customer_id": coustomerId,
        "device_type": Platform.isAndroid ? "android" : "ios",
        "app_version": Endpoints.AppVersionCode,
        "notification_key": fcm_token
      };
      var headers = {"Authorization": token};
      Response response = await _dio.post(Endpoints.addNotification,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      if (response.statusCode == 200) {
        if (response.toString().contains("statusCode")) {
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
            return AddNotificationResponse(success: false, data: "");
          }
          return AddNotificationResponse(success: false, data: "");
        } else {
          getnotificationList(() {});
          return AddNotificationResponse.fromJson(response.data);
        }
      } else {
        return AddNotificationResponse(
            data: "Something Went Wrong!!", success: false);
      }
    } catch (excpetion, stackTrace) {
      String message = "";
      if (excpetion is DioException) {
        ServerError e = ServerError.withError(error: excpetion);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stackTrace");
      return AddNotificationResponse(data: message, success: false);
    }
  }

  Future<ChangeDeliverySlotResponse> changeDeliverySlotApi(
      {required String deliveryTimeSlot,
      required String deliveryDateSlot,
      required String orderId,
      required Function callback}) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      String mobileNumber =
          await SharedPref.getStringPreference(Constants.sp_MOBILE_NO);

      String token = "$token_type $access_token";
      var headers = {"Authorization": token};
      var data = {
        "customer_id": coustomerId,
        "delivery_date": deliveryDateSlot,
        "delivery_time": deliveryTimeSlot,
        "telephone": mobileNumber,
        "order_id": orderId
      };

      Response response = await _dio.post(Endpoints.changeDeliverySlot,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      if (response.statusCode == 200) {
        if (response.toString().contains("statusCode") &&
            token.trim().isNotEmpty) {
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
          return ChangeDeliverySlotResponse(success: false, message: "");
        }
        ChangeDeliverySlotResponse changeDeliverySlotResponse =
            ChangeDeliverySlotResponse.fromJson(response.data);
        return changeDeliverySlotResponse;
      } else {
        return ChangeDeliverySlotResponse(
            success: false, message: response.statusMessage);
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ChangeDeliverySlotResponse(success: false, message: message);
    }
  }

  Future<ShoppingListModificationResponse> deleteShoppingList(
      String shoppingListID) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var data = {
        "customer_id": coustomerId,
        "shopping_list_id": shoppingListID
      };
      var headers = {"Authorization": token};
      Response response = await _dio.post(Endpoints.deleteShoppingList,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      var deleteShoppingListdata = jsonDecode(response.data);
      if (response.toString().contains('statusCode') &&
          token.trim().isNotEmpty) {
        int statuscode = deleteShoppingListdata['statusCode'];
        String statusText = deleteShoppingListdata['statusText'];
        SessionExpire(navigationService.navigatorKey.currentContext!, () {});
        return ShoppingListModificationResponse(success: false, message: "");
      }
      ShoppingListModificationResponse shoppingListModificationResponse =
          ShoppingListModificationResponse.fromJson(response.data.toString());
      return shoppingListModificationResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ShoppingListModificationResponse();
    }
  }

  Future<ProductsModel> shopByCAtegoryApi(
      String categoryID, String sortingIndex, int pageNumber) async {
    String wmsStoreid =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID) ?? "";
    String storeCode =
        await SharedPref.getStringPreference(Constants.STORE_CODE) ?? "";
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID) ?? "";
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId) ?? "";
    var headers = {
      "customer_id": coustomerId,
      "wmsstoreid": wmsStoreid,
      "storecode": storeCode,
      "location_id": location_id,
      "device_type": Platform.isAndroid ? "android" : "ios"
    };
    print("ROHITTTT ${headers}");
    try {
      Response response = await _dio.get(
          "${Endpoints.getCategoriesItemV1}/$location_id/$categoryID/$sortingIndex/$pageNumber",
          options: Options(headers: headers),
          cancelToken: cancelToken);
      ProductsModel shopByCategoryResponse =
          ProductsModel.fromJson(response.data.toString());
      return shopByCategoryResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ProductsModel(success: false, data: []);
    }
  }

  Future<ProductsModel> getFilteredData(String categoryID, String sortingIndex,
      int pageNumber, List<FilterDataParams> filterDataParams) async {
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    var body = {
      "category_id": categoryID,
      "sorting_type": sortingIndex,
      "location_id": location_id,
      "page_no": pageNumber,
      "filter_data": filterDataParams
    };
    try {
      print("GET FILTER DATA BODY ${jsonEncode(body)}");
      Response response = await _dio.get(Endpoints.getFilterData,
          cancelToken: cancelToken, data: body);
      ProductsModel shopByCategoryResponse =
          ProductsModel.fromJson(response.data.toString());
      print("Filter Response ${response.toString()}");
      return shopByCategoryResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ProductsModel(success: false, data: []);
    }
  }

  Future<GetFilterResponse> getFilterData(String categoryId) async {
    try {
      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      var body = {"category_id": categoryId, "location_id": location_id};
      Response response = await _dio.get(Endpoints.getFilter,
          cancelToken: cancelToken, data: body);
      if (response.statusCode == 200) {
        GetFilterResponse getFilterResponse =
            GetFilterResponse.fromJson(jsonDecode(response.data));
        return getFilterResponse;
      } else {
        return GetFilterResponse(
            success: false, data: FilterData(filterGroups: []));
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetFilterResponse(
          success: false, data: FilterData(filterGroups: []));
    }
  }

  Future<SaveOrdertoDatabaseResponse> saveOrdertoDataBase(
      bodyData, Function callBack) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String store_id =
          await SharedPref.getStringPreference(Constants.STORE_ID);
      String store_code =
          await SharedPref.getStringPreference(Constants.STORE_CODE);
      String store_name =
          await SharedPref.getStringPreference(Constants.STORE_Name);
      String wms_store_id =
          await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String token = "$token_type ${access_token}";
      var headers = {
        "Authorization": token,
        "ondoor_app_code": Endpoints.AppVersionCode,
        "wmsstoreid": wms_store_id,
        "storename": store_name,
        "device_type": Platform.isAndroid ? "android" : "ios",
        "customer_id": coustomerId,
        "storeid": store_id,
        "location_id": location_id,
        "storecode": store_code
      };
      print("SAVE ORDER HEADERS ${headers}");
      log("SAVE ORDER Body ${json.encode(bodyData)}");

      Response response = await _dio.post(Endpoints.saveOrdertoDataBase,
          data: bodyData,
          cancelToken: cancelToken,
          options: Options(headers: headers, preserveHeaderCase: true));
      if (response.statusCode == 200) {
        if (response.data.toString().contains("statusText")) {
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");
          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callBack);
          }
          return SaveOrdertoDatabaseResponse(success: false, message: "");
        } else {
          SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse =
              SaveOrdertoDatabaseResponse.fromJson(response.data);
          return saveOrdertoDatabaseResponse;
        }
      } else {
        return SaveOrdertoDatabaseResponse.fromJson(response.data);
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return SaveOrdertoDatabaseResponse(message: message, success: false);
    }
  }

  Future<ProductsModel> getProductFromShoppingList(
      String shoppingListID) async {
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

    String token = "$token_type $access_token";
    var data = {"customer_id": coustomerId, "shopping_list_id": shoppingListID};
    var headers = {"Authorization": token};
    try {
      Response response = await _dio.post(Endpoints.productFromShoppingList,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      ProductsModel shopByCategoryResponse =
          ProductsModel.fromJson(response.data.toString());
      return shopByCategoryResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ProductsModel(success: false, data: []);
    }
  }

  Future<NotificationListResponse> getnotificationList(
      Function callback) async {
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String token = "$token_type $access_token";
    var headers = {
      "Authorization": token,
      "ondoor_app_code": Endpoints.AppVersionCode,
      "wmsstoreid": wms_store_id,
      "storename": store_name,
      "device_type": Platform.isAndroid ? "android" : "ios",
      "customer_id": coustomerId,
      "storeid": store_id,
      "location_id": location_id,
      "storecode": store_code
    };

    var data = {"customer_id": coustomerId, "send_at": 1};
    try {
      Response response = await _dio.post(Endpoints.notificationList,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      NotificationListResponse notificationListResponse =
          NotificationListResponse();

      if (response.data.toString().contains("statusText")) {
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");
        if (statuscode.toString() == "401") {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
          return NotificationListResponse(
              success: false,
              data: [],
              statusText: statusText,
              statusCode: statuscode);
        }
        return NotificationListResponse(
            success: false,
            data: [],
            statusCode: statuscode,
            statusText: statusText);
      } else {
        notificationListResponse =
            NotificationListResponse.fromJson(response.data);
      }
      await SharedPref.setStringPreference(Constants.sp_NotificationCount,
          notificationListResponse!.data!.length!.toString());

      return notificationListResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return NotificationListResponse(success: false, data: []);
    }
  }

  Future<OrderHistoryDetailResponse> getOrderHistoryDetail(
      String order_ID, String order_type, Function callback) async {
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

    String token = "$token_type $access_token";

    try {
      var data = {
        "customer_id": coustomerId,
        "order_id": order_ID,
        "type": order_type
      };
      var headers = {"Authorization": token};

      print("getOrderByOrderIDExtendedFV1 input: $data");

      Response response = await _dio.get(Endpoints.getOrderByOrderIDExtendedFV1,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      if (response.data.toString().contains("statusCode")) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
      }

      OrderHistoryDetailResponse? cocoCodeByLatLngResponse;
      if (response.data is String) {
        var responseData = json.decode(response.data);
        cocoCodeByLatLngResponse =
            OrderHistoryDetailResponse.fromJson(responseData);
      } else {
        cocoCodeByLatLngResponse =
            OrderHistoryDetailResponse.fromJson(response.data);
      }
      return cocoCodeByLatLngResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return OrderHistoryDetailResponse(
          success: false, data: OrderHistoryDetailData());
    }
  }

  Future<GetCocoCodeByLatLngResponse> getCocoCodeByLatLngApi(double latitude,
      double longitude, String cityName, String stateName) async {
    var data = {
      "latitude": latitude,
      "longitude": longitude,
      "city": cityName,
      "state": stateName
    };
    try {
      print("COCO BODY ${data}");
      Response response = await _dio.get(Endpoints.cocoByLatLng,
          cancelToken: cancelToken, data: data);
      GetCocoCodeByLatLngResponse cocoCodeByLatLngResponse =
          GetCocoCodeByLatLngResponse.fromJson(response.data.toString());
      return cocoCodeByLatLngResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetCocoCodeByLatLngResponse(
          success: false,
          changeAddressMessage: message,
          message: message,
          data: CoCoCodeData(
              storeId: "",
              storeCode: "",
              storeName: "",
              locationId: "",
              wmsStoreId: "",
              cityName: "",
              telephone: "",
              distance: "",
              inputLat: "",
              inputLng: ""));
    }
  }

  Future<ProductsModel> getFeaturedProduct(String type) async {
    var data = json.encode({"type": type});

//  try {

    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);

    Response response = await _dio.post(
      Endpoints.getFeaturedProduct,
      cancelToken: cancelToken,
      data: data,
      options: Options(
        headers: {
          'location_id':
              '$location_id', // Replace 'your_value_here' with your actual value
        },
      ),
    );
    ProductsModel productsModel = ProductsModel.fromJson(response.toString());
    return productsModel;
  }

  Future<OrderOnPhoneResponse> getOrderonPhone() async {
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    try {
      Response response = await _dio.post(Endpoints.getOrderonPhone,
          cancelToken: cancelToken,
          options: Options(headers: {"location_id": location_id}));
      OrderOnPhoneResponse orderOnPhoneResponse =
          OrderOnPhoneResponse.fromJson(json.decode(response.data.toString()));
      return orderOnPhoneResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return OrderOnPhoneResponse();
    }
  }

  Future<CancelOrderbyOrderIdResponse> cancelOrder(
      {required String mobileNumber,
      required String orderId,
      required Function callback}) async {
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    try {
      String customerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {
        "customer_id": customerId,
        "order_id": orderId,
        "location_id": location_id,
        "telephone": mobileNumber,
        "is_wallet_transfer": "1"
      };
      Response response = await _dio.post(Endpoints.cancelOrderbyOrderId,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token.trim(),
          }));
      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        return CancelOrderbyOrderIdResponse(success: false);
      } else {
        CancelOrderbyOrderIdResponse cancelOrderbyOrderIdResponse =
            CancelOrderbyOrderIdResponse.fromJson(response.data);
        return cancelOrderbyOrderIdResponse;
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      log("Exception occurred: $message stackTrace: $stacktrace");
      return CancelOrderbyOrderIdResponse(success: false, message: message);
    }
  }

  Future<ContactUsReasonListResponse> getContactReasons() async {
    try {
      Response response = await _dio.post(
        Endpoints.getContactUs,
        cancelToken: cancelToken,
      );
      ContactUsReasonListResponse contact_us_reason_list_response =
          ContactUsReasonListResponse.fromJson(response.data.toString());
      return contact_us_reason_list_response;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ContactUsReasonListResponse(message: message);
    }
  }

  Future<GetPagesResponse> getpages(String page_id) async {
    try {
      var data = {"information_id": page_id};
      Response response = await _dio.post(Endpoints.getPage,
          cancelToken: cancelToken, data: data);
      GetPagesResponse contact_us_reason_list_response =
          GetPagesResponse.fromJson(json.decode(response.data.toString()));
      return contact_us_reason_list_response;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetPagesResponse();
    }
  }

  Future<ContactUsResponse> contactUsApi({
    required String userName,
    required String isProduct,
    required String email,
    required String telephone,
    required String enquiry,
    required String enquiryfor,
    required String order_id,
    required String complain_type,
    required String category_id,
    required String sub_category_id,
    required String comment_box,
  }) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      var body = {
        "telephone": telephone,
        "email": email,
        "enquiryfor": enquiryfor,
        "order_id": order_id,
        "user_id": coustomerId,
        "enquiry": comment_box,
        "name": userName,
        "complain_type": complain_type,
        "category_id": category_id,
        "sub_category_id": sub_category_id,
        "is_product": isProduct,
        "products": [],
        "comment_box": 1
      };
      Response response = await _dio.post(Endpoints.contactUs,
          cancelToken: cancelToken, data: body);
      ContactUsResponse contactUsResponse = ContactUsResponse();
      if (response.statusCode == 200) {
        contactUsResponse =
            ContactUsResponse.fromJson(response.data.toString());
      } else {
        print("RESPONSE STATUS MESSAGE ${response.statusMessage}");
        contactUsResponse = ContactUsResponse(
            success: false, message: response.statusMessage, productMsg: "");
      }
      return contactUsResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ContactUsResponse(message: message);
    }
  }

  Future<GetLatestOrderResponse> getLatestOrderResponse(
      String id, Function callback) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {"customer_id": coustomerId.trim(), "selected_reason": id};
      Response response = await _dio.get(Endpoints.getLatestOrder,
          cancelToken: cancelToken,
          data: body,
          options: Options(headers: {
            'Authorization': token.trim(),
          }, preserveHeaderCase: true));
      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        return GetLatestOrderResponse(success: false);
      }
      GetLatestOrderResponse getLatestOrderResponse =
          GetLatestOrderResponse.fromJson(
              json.decode(response.data.toString()));
      return getLatestOrderResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetLatestOrderResponse(message: message);
    }
  }

  Future<GetOrderHistoryResponse> getOrderHistory(
      String archive_id,
      String customerId,
      String token,
      String location_id,
      Function callback) async {
    try {
      var body = {
        "customer_id": customerId,
        "location_id": location_id,
        "archive": archive_id
      };

      Response response = await _dio.post(
        Endpoints.getOrderbyCustomerId,
        cancelToken: cancelToken,
        data: body,
        options: Options(
          headers: {
            'Authorization': token,
          },
          preserveHeaderCase: true,
        ),
      );

      // Print response data type

      // Check if response data is a Map
      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        return GetOrderHistoryResponse(success: false, data: []);
      }
      if (response.data['data'] is List) {
        return GetOrderHistoryResponse.fromJson(response.data);
      } else {
        // Handle unexpected data format
        debugPrint(
            "Unexpected response format ${response.data['data']['error']}");
        return GetOrderHistoryResponse(
            success: false, data: [], error: response.data['data']['error']);
      }
    } catch (error, stacktrace) {
      String message;
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something went wrong";
      }
      debugPrint(
          "Exception occurred: ${error.toString()} stackTrace: $stacktrace");
      return GetOrderHistoryResponse(success: false, error: message);
    }
  }

  Future<RewardSummaryResponse> getRewardSummary() async {
    RewardSummaryResponse rewardSummaryResponse = RewardSummaryResponse();
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {"customer_id": coustomerId /*, "address_id": "1"*/};
      print("REWARD ${body}");
      Response response = await _dio.post(Endpoints.rewardSummary,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token,
          }));
      if (response.statusCode == 200) {
        rewardSummaryResponse =
            RewardSummaryResponse.fromJson(response.data.toString());
        return rewardSummaryResponse;
      } else {
        rewardSummaryResponse =
            RewardSummaryResponse.fromJson(response.data.toString());
        return rewardSummaryResponse;
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return RewardSummaryResponse(success: false);
    }
  }

  Future<GetProfileResponse> getProfileData(Function callback) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {"customer_id": coustomerId /*, "address_id": "1"*/};
      Response response = await _dio.post(Endpoints.getProfile,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token,
          }));

      GetProfileResponse getProfileResponse = GetProfileResponse();
      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        var profileData = GetProfileResponse(
                data: ProfileData(firstname: "Guest", lastname: "User"),
                success: false)
            .toJson();
        getProfileResponse = GetProfileResponse.fromJson(profileData);
      } else {
        getProfileResponse = GetProfileResponse.fromJson(response.data);
      }

      return getProfileResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetProfileResponse(success: false, data: ProfileData());
    }
  }

  Future<GetShoppingListResponse> getShoppingList(Function callback) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {"customer_id": coustomerId};
      Response response = await _dio.post(Endpoints.getshoppingList,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token,
          }));

      GetShoppingListResponse? getShoppingListResponse;
      if (response.data.toString().contains("statusCode")) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        var shoppingListdata =
            GetShoppingListResponse(shoppinglist: [], success: false).toJson();
        getShoppingListResponse =
            GetShoppingListResponse.fromJson(shoppingListdata);
      } else {
        getShoppingListResponse =
            GetShoppingListResponse.fromJson(response.data);
      }

      return getShoppingListResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetShoppingListResponse(success: false, shoppinglist: []);
    }
  }

  Future<GetTimeSlotResponse> getTimeSlots(String locationId, String addressId,
      String startDate, Function callback) async {
    try {
      String tokenType =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String accessToken =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$tokenType $accessToken";
      var body = {
        "location_id": locationId,
        "address_id": addressId,
        "start_date": startDate
      };
      Response response = await _dio.post(Endpoints.getTimeSlot,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token,
          }));
      if (response.statusCode == 200) {
        String res = response.toString();
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
          return GetTimeSlotResponse(
              data: [],
              message: "",
              success: false,
              statusCode: statuscode,
              statusText: statusText);
        }
        return GetTimeSlotResponse.fromJson(res);
      } else {
        String responseStr = jsonDecode(response.data.toString());
        return GetTimeSlotResponse.fromJson(responseStr);
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return GetTimeSlotResponse(success: false, data: []);
    }
  }

  Future<TimeSlotResponse> getTimeSlots2(
      String locationId, String startDate, Function callback) async {
    try {
      String tokenType =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String accessToken =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$tokenType $accessToken";
      var body = {"location_id": locationId, "start_date": startDate};
      Response response = await _dio.post(Endpoints.getTimeSlotApi,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token,
          }));
      if (response.statusCode == 200) {
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
          return TimeSlotResponse(
              data: [], success: false, dateText: "", selectDateText: "");
        }

        return TimeSlotResponse.fromJson(response.data);
      } else {
        return TimeSlotResponse.fromJson(response.data);
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return TimeSlotResponse(success: false, data: []);
    }
  }

  Future<AddShoppingListResponse> addShoppingList(
      String shoppingListName) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {"customer_id": coustomerId, "name": shoppingListName};
      Response response = await _dio.post(Endpoints.addshoppingList,
          data: body,
          cancelToken: cancelToken,
          options: Options(headers: {
            'Authorization': token,
          }));

      AddShoppingListResponse? addShoppingListResponse;
      if (response.data.toString().contains("error")) {
        var dataFromAPi = json.decode(response.data.toString());
        var data = AddShoppingListResponse(
                message: dataFromAPi['error'], success: false)
            .toJson();
        addShoppingListResponse = AddShoppingListResponse.fromJson(data);
      } else {
        addShoppingListResponse =
            AddShoppingListResponse.fromJson(response.data);
      }

      return addShoppingListResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return AddShoppingListResponse(success: false, message: message);
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String firstName,
      String lastName,
      String emailID,
      String gstnumber,
      String firmname,
      Function callback) async {
    try {
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {
        "customer_id": coustomerId,
        "firstname": firstName,
        "lastname": lastName,
        "email": emailID,
        "gst_no": gstnumber,
        "gst_firm_name": firmname
      };

      Response response = await _dio.post(
        Endpoints.editProfile,
        data: body,
        cancelToken: cancelToken,
        options: Options(
          headers: {'Authorization': token},
        ),
      );

      // Check response status code
      if (response.statusCode == 200) {
        // Parse response data
        // Map<String, dynamic> data = json.decode(response.data.toString());
        if (response.data.toString().contains("statusCode") ||
            response.data.toString().isEmpty) {
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
          return response.data as Map<String, dynamic>;
        } else {
          return response.data as Map<String, dynamic>;
        }
      } else {
        // Handle non-200 status codes if needed
        debugPrint("Error: ${response.statusCode}");
        return {}; // Return an empty map or handle as needed
      }
    } catch (error, stacktrace) {
      // Handle errors
      String message = "Exception occurred: Something went wrong";
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return {}; // Return an empty map or handle as needed
    }
  }

  Future<dynamic> registerUser(String name, String mobile, String email,
      BuildContext context, bool isresend, String fromRoute) async {
    // EasyLoading.show();
    Response response;
    try {
      var data = json.encode({"name": name, "mobile": mobile, "email": email});

      response = await _dio.post(
        Endpoints.registerduser,
        data: data,
        cancelToken: cancelToken,
        options: Options(
          headers: {'device_type': Platform.isIOS ? "ios" : 'android'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        final message = responseData['data'];
        bool success = responseData['success'];
        if (success) {
          Appwidgets.showToastMessage(message);

          if (isresend == false) {
            await SmsAutoFill().getAppSignature;

            Navigator.pushReplacementNamed(
              context,
              Routes.verify_screen,
              arguments: {
                'name': name,
                'mobile': mobile,
                'email': email,
                "fromRoute": fromRoute
              },
            ).then((value) {});
          }
        }
        debugPrint("registerUser>>>>$message");
      }

      EasyLoading.dismiss();
    } catch (error, stacktrace) {
      EasyLoading.dismiss();
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ProductsModel(success: false, data: []);
    }

    return response;
  }

  Future<RegisterResponse> registerUserwithoutRoute(
      String name,
      String mobile,
      String email,
      BuildContext context,
      bool isresend,
      String fromRoute) async {
    // EasyLoading.show();
    Response response;
    RegisterResponse registerResponse = RegisterResponse();
    try {
      var data = json.encode({"name": name, "mobile": mobile, "email": email});

      response = await _dio.post(
        Endpoints.registerduser,
        data: data,
        cancelToken: cancelToken,
        options: Options(
          headers: {'device_type': Platform.isIOS ? "ios" : 'android'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        registerResponse = RegisterResponse.fromJson(responseData);
        final message = responseData['data'];
        bool success = responseData['success'];
        if (success) {
          Appwidgets.showToastMessage(message);

          if (isresend == false) {
            await SmsAutoFill().getAppSignature;
          }
        }
        debugPrint("registerUser>>>>$message");
        return registerResponse;
      }

      EasyLoading.dismiss();
    } catch (error, stacktrace) {
      EasyLoading.dismiss();
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return RegisterResponse(success: false, data: '');
    }

    return registerResponse;
  }

  Future<dynamic> verifyOtp(
      String OTP, String mobile, BuildContext context, String fromRoute) async {
    EasyLoading.show();
    Response response;
    try {
      var data = json.encode({
        "token": OTP,
        "mobile": mobile,
      });

      response = await _dio.post(
        Endpoints.verifyotp,
        data: data,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != "") {
        final responseData = jsonDecode(response.data);

        bool success = responseData['success'];
        if (!success) {
          final message = responseData['error'];
          Appwidgets.showToastMessage(message);
        } else {
          VerifyModel verifyModel = VerifyModel.fromJson(response.toString());

          SharedPref.setIntegerPreference(
              Constants.sp_CREDIT_PROGRAM, verifyModel.creditprogram!);
          SharedPref.setStringPreference(
              Constants.sp_CustomerId, verifyModel.data!.customerId!);
          SharedPref.setStringPreference(
              Constants.sp_FirstNAME, verifyModel.data!.firstname!);
          SharedPref.setStringPreference(
              Constants.sp_LastName, verifyModel.data!.lastname!);
          SharedPref.setStringPreference(
              Constants.sp_EMAIL, verifyModel.data!.email!);
          SharedPref.setStringPreference(
              Constants.sp_MOBILE_NO, verifyModel.data!.telephone!);
          SharedPref.setStringPreference(
              Constants.sp_TOKEN, verifyModel.data!.token!);
          // SharedPref.setStringPreference(
          //     Constants.LOCATION_ID, verifyModel.locations![0].locationId!);
          // SharedPref.setStringPreference(
          //     Constants.LOCATION_NAME, verifyModel.locations![0].name!);

          debugPrint("TOKEN >>  " + verifyModel.data!.token!);
          debugPrint("TOKEN >>  " + verifyModel.toJson());

          getToken(
              verifyModel.data!.token!,
              verifyModel.locations![0].locationId!,
              verifyModel.data!.customerId!,
              context,
              fromRoute);
        }
      }

      EasyLoading.dismiss();
    } catch (error, stacktrace) {
      EasyLoading.dismiss();
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return ProductsModel(success: false, data: []);
    }

    return response;
  }

  Future<dynamic> getToken(String token, String location_id, String customer_id,
      BuildContext context, String fromRoute) async {
    String fcmToken = "";
    // String serverToken = "";
    EasyLoading.show();
    Response response;
    // try {
    var data = json.encode({
      "location_id": location_id,
      "customer_id": customer_id,
      "fcm_token": fcmToken
    });

    response = await _dio.post(
      Endpoints.getToken,
      data: data,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization':
              'Basic $token', // Replace 'your_value_here' with your actual value
        },
      ),
    );

    if (response.statusCode == 200) {
      await MyUtility().getFcmToken();

      final responseData = jsonDecode(response.toString());

      final access_token = responseData['access_token'];
      final expires_in = responseData['expires_in'];
      final token_type = responseData['token_type'];

      SharedPref.setStringPreference(Constants.sp_AccessTOEKN, access_token);
      SharedPref.setStringPreference(Constants.sp_TOKENTYPE, token_type);
      SharedPref.setStringPreference(
          Constants.sp_TOKENEXPIREIN, expires_in.toString());

      debugPrint("TOKEN >>  " + access_token);

      String routeName =
          await SharedPref.getStringPreference(Constants.sp_VerifyRoute);
      debugPrint("TOKEN >>  $routeName");
      debugPrint("TOKEN >>  $fromRoute");

      switch (routeName) {
        case Routes.home_page:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pushReplacementNamed(context, Routes.home_page);
          break;

        // case Routes.payment_option:
        //   await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
        //   List<ProductUnit> cartItems = [];
        //   String cartItemsData =
        //       await SharedPref.getStringPreference(Constants.CART_ITEMS);
        //   print("CART ITEM DATA VALUE ${cartItemsData}");
        //   cartItems.add(ProductUnit.fromJson(cartItemsData));
        //   print("CART ITEM DATA VALUE ${cartItems.length}");
        //   await SharedPref.setStringPreference(Constants.CART_ITEMS, "");
        //   Navigator.pushReplacementNamed(context, Routes.payment_option,
        //       arguments: cartItems);
        //   break;

        case Routes.order_history:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pushReplacementNamed(context, Routes.order_history);
          break;

        case Routes.shopping_list:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pushReplacementNamed(context, Routes.shopping_list);

          break;
        case Routes.location_screen:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pushReplacementNamed(context, Routes.location_screen);
          break;
        case Routes.notification_center:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pushReplacementNamed(context, Routes.notification_center);

          break;
        case Routes.edit_profile:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pushReplacementNamed(context, Routes.edit_profile);
          break;
        case Routes.change_address:
          // await SharedPref.setBooleanPreference(Constants.locationupdate, true);
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          if (routeName == Routes.change_address &&
              fromRoute == Routes.checkoutscreen) {
            SharedPref.setStringPreference(Constants.sp_fromRoute, fromRoute);
          }
          Navigator.pushReplacementNamed(context, Routes.change_address,
              arguments: fromRoute);
          break;
        case Routes.checkoutscreen:
          await SharedPref.setStringPreference(Constants.sp_VerifyRoute, "");
          Navigator.pop(context);
          //
          // Navigator.pushReplacementNamed(context, Routes.checkoutscreen);
          break;

        default:
          Navigator.pushReplacementNamed(context, Routes.home_page);
      }
      if (customer_id.trim().isNotEmpty) {
        await addNotiFication(() {
          addNotiFication(() {});
        });
      }
      // serverToken = await MyUtility.getServerToken();
    }

    EasyLoading.dismiss();
    // } catch (error, stacktrace) {
    //   EasyLoading.dismiss();
    //   String message = "";
    //   if (error is DioException) {
    //     ServerError e = ServerError.withError(error: error);
    //     message = e.getErrorMessage();
    //   } else {
    //     message = "Something Went wrong";
    //   }
    //   debugPrint("Exception occurred: $message stackTrace: $stacktrace");
    //   return ProductsModel(success: false, data: []);
    // }

    return response;
  }

  Future<dynamic> getTokenRegenrate(String token, String location_id,
      String customer_id, BuildContext context, Function fromRoute) async {
    String fcmToken = "";
    // String serverToken = "";
    EasyLoading.show();
    Response response;
    // try {
    var data = json.encode({
      "location_id": location_id,
      "customer_id": customer_id,
      "fcm_token": fcmToken
    });

    response = await _dio.post(
      Endpoints.getToken,
      data: data,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization':
              'Basic $token', // Replace 'your_value_here' with your actual value
        },
      ),
    );

    if (response.statusCode == 200) {
      await MyUtility().getFcmToken();

      final responseData = jsonDecode(response.toString());
      EasyLoading.dismiss();

      if (response.toString().contains("error")) {
        if (responseData["error"] == "invalid_client") {
          print("GETTOKEN ${responseData}");
          SharedPref.setStringPreference(Constants.sp_TOKEN, "");
          SharedPref.setStringPreference(Constants.sp_AccessTOEKN, "");
          SharedPref.setStringPreference(Constants.sp_TOKENTYPE, "");
          SharedPref.setStringPreference(Constants.sp_TOKENEXPIREIN, "");
          SharedPref.setStringPreference(Constants.sp_CustomerId, "");
          Navigator.pushReplacementNamed(context, Routes.home_page);
        }
      } else {
        final access_token = responseData['access_token'];
        final expires_in = responseData['expires_in'];
        final token_type = responseData['token_type'];

        SharedPref.setStringPreference(Constants.sp_AccessTOEKN, access_token);
        SharedPref.setStringPreference(Constants.sp_TOKENTYPE, token_type);
        SharedPref.setStringPreference(
            Constants.sp_TOKENEXPIREIN, expires_in.toString());

        debugPrint("TOKEN >>  " + access_token);

        String routeName =
            await SharedPref.getStringPreference(Constants.sp_VerifyRoute);
        debugPrint("TOKEN >>  $routeName");
        debugPrint("TOKEN >>  $fromRoute");

        fromRoute();

        //  await addNotiFication();
        // serverToken = await MyUtility.getServerToken();
      }
    }

    EasyLoading.dismiss();
    // } catch (error, stacktrace) {
    //   EasyLoading.dismiss();
    //   String message = "";
    //   if (error is DioException) {
    //     ServerError e = ServerError.withError(error: error);
    //     message = e.getErrorMessage();
    //   } else {
    //     message = "Something Went wrong";
    //   }
    //   debugPrint("Exception occurred: $message stackTrace: $stacktrace");
    //   return ProductsModel(success: false, data: []);
    // }

    return response;
  }

  Future<GetCityResponse> getCityListApi() async {
    // try {
    Response response = await _dio.get(
      Endpoints.getCities,
      cancelToken: cancelToken,
    );
    GetCityResponse getCityResponse =
        GetCityResponse.fromJson(json.decode(response.toString()));
    return getCityResponse;
    // } catch (error, stacktrace) {
    //   String message = "";
    //   if (error is DioException) {
    //     ServerError e = ServerError.withError(error: error);
    //     message = e.getErrorMessage();
    //   } else {
    //     message = "Something Went wrong";
    //   }
    //   debugPrint("Exception occurred: $message stackTrace: $stacktrace");
    //   return GetCityResponse();
    // }
  }

  SessionExpire(BuildContext context, Function callback) async {
    String token = await SharedPref.getStringPreference(Constants.sp_TOKEN);
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String customer_id =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    getTokenRegenrate(token, location_id, customer_id, context, callback);
  }

  Future<AddressListResponse> getAddressListApi(
      String customer_id, String isCredit, Function callback) async {
    String customer_id =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

    String token = "$token_type $access_token";
    try {
      var body = {"customer_id": customer_id, "is_credit": isCredit};
      Response response = await _dio.get(
        Endpoints.listAddress,
        data: body,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );
      if (response.statusCode == 200) {
        AddressListResponse addressListResponse = AddressListResponse();
        if (response.data.toString().contains("statusCode") ||
            response.data.toString().isEmpty) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
          return AddressListResponse(
              success: false,
              statusCode: statuscode,
              statusText: statusText,
              data: [],
              gstInfo: GstInfo());
        } else {
          addressListResponse = AddressListResponse.fromJson(response.data);
        }
        return addressListResponse;
      } else {
        return AddressListResponse(
            success: false, data: [], gstInfo: GstInfo());
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return AddressListResponse(
          success: false, data: <AddressData>[], gstInfo: GstInfo());
    }
  }

  Future<DeleteAddressResponse> deleteAddressApi(
      String address_id, Function callback) async {
    // String token = "";

    try {
      String customer_id =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var body = {"customer_id": customer_id, "address_id": address_id};
      Response response = await _dio.get(
        Endpoints.deleteAddress,
        data: body,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );
      if (response.statusCode == 200) {
        if (response.data.toString().contains("statusCode") ||
            response.data.toString().isEmpty) {
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
        }
        // String responseData = response.data.toString();
        DeleteAddressResponse deleteAddressResponse =
            DeleteAddressResponse.fromJson(response.data);
        return deleteAddressResponse;
      } else {
        return DeleteAddressResponse(success: false);
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return DeleteAddressResponse(success: false);
    }
  }

  Future<AddressResponse> addAddressApi(
      Map<String, dynamic> body, Function callback) async {
    try {
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
        'Cookie':
            'PHPSESSID=bt9m6ftm9aj9n0vcetg6m5u5la; currency=INR; language=en'
      };
      log("ADD ADDRESS BODY ${body}");
      Response response = await _dio.get(Endpoints.addAddress,
          cancelToken: cancelToken,
          data: body,
          options: Options(headers: headers));
      // if (response.statusCode == 200) {
      //   addressResponse = AddressResponse.fromJson(json.decode(response.data));
      // } else {
      // }

      if (response.data.toString().contains("statusCode") ||
          response.data.toString().isEmpty) {
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
      }
      AddressResponse addressResponse =
          AddressResponse.fromJson(json.decode(response.data));

      return addressResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return AddressResponse(success: false, message: message);
    }
  }

  Future<String> getSearchProduct(
      String key, BuildContext context, int pageno, bool editOrder) async {
    print("getSearchProduct >> $editOrder");
    //EasyLoading.show();
    //
    // if (pageno == 1) {
    //   MyDialogs.showLoadingDialog(context);
    // }

    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;
    try {
      String url = "";
      var header;
      if (editOrder == false) {
        url = "${Endpoints.getSeachProductV1}/$key/$location_id/$pageno";
        header = {
          'location_id': '$location_id',
          'wmsstoreid': '$wms_store_id',
          'storecode': '$store_code',
        };
      } else {
        String orderId = await SharedPref.getStringPreference("OrderId") ?? "";
        url = "${Endpoints.getEditSearchProduct}/$key/$orderId/$location_id";
        String token_type =
            await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
        String access_token =
            await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
        String customer_id =
            await SharedPref.getStringPreference(Constants.sp_CustomerId);

        String token = "$token_type $access_token";
        print("getSearchProduct token >> $token");
        header = {
          "ondoor_app_code": Endpoints.AppVersionCode,
          'wmsstoreid': '$wms_store_id',
          'storename': '$store_name',
          'device_type': Platform.isAndroid ? "android" : "ios",
          'customer_id': customer_id,
          'storeid': '$store_id',
          'location_id': '$location_id',
          'storecode': '$store_code',
          'Authorization': token
        };
      }
      Response response = await _dio.post(
        // Endpoints.getSeachProductV1 + "/{$key}/$location_id/$pageno",
        url,
        cancelToken: cancelToken,
        options: Options(
          headers: header,
        ),
      );
      final responseData = jsonDecode(response.toString());
      if (responseData['success'] == false) {
        //EasyLoading.dismiss();
        // if (pageno == 1) {
        //   Navigator.pop(context);
        // }

        return "";
      }

      ProductsModel productsModel = ProductsModel.fromJson(response.toString());
      // EasyLoading.dismiss();
      // if (pageno == 1) {
      //   Navigator.pop(context);
      // }

      return response.toString();
    } catch (e) {
      // EasyLoading.dismiss();
      // if (pageno == 1) {
      //   Navigator.pop(context);
      // }
      return "";
    }
  }

  Future<String> getSimilarProducts(String key, int pageno) async {
    var wms_stroeId =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    // var store_code= await SharedPref.getStringPreference(Constants.STORE_CODE);
    // var store_id= await SharedPref.getStringPreference(Constants.STORE_ID);
    // var stroe_name=await  SharedPref.getStringPreference(Constants.STORE_Name);
    var location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // var lat= await SharedPref.getStringPreference(Constants.LOCATION_LAT);
    // var log=await  SharedPref.getStringPreference(Constants.LOCATION_LONG);
    //
    debugPrint("WmsStrotre Id ${wms_stroeId}");

    if (pageno > 1) {
    } else {
      // EasyLoading.show();
    }

    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;

    var data = {
      "product_ids": "$key",
      "location_id": "$location_id",
      "wmsstoreid": "$wms_stroeId",
    };

    try {
      Response response = await _dio.post(
          Endpoints.getSimilarProducts + "&page_no=${pageno}",
          cancelToken: cancelToken,
          options: Options(headers: data));
      final responseData = jsonDecode(response.toString());

      //log("GGAAGGG ${responseData}");

      // if (responseData['success'] == false) {
      //   EasyLoading.dismiss();
      //   return "";
      // }

      ProductData productsModel = ProductData.fromJson(response.toString());

      // EasyLoading.dismiss();

      return response.toString();
    } catch (e) {
      // EasyLoading.dismiss();
      return "";
    }
  }

  Future<String> beforeYourCheckout(
      String key, int pageno, BuildContext context) async {
    var wms_stroeId =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    // var store_code= await SharedPref.getStringPreference(Constants.STORE_CODE);
    // var store_id= await SharedPref.getStringPreference(Constants.STORE_ID);
    // var stroe_name=await  SharedPref.getStringPreference(Constants.STORE_Name);
    var location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // var lat= await SharedPref.getStringPreference(Constants.LOCATION_LAT);
    // var log=await  SharedPref.getStringPreference(Constants.LOCATION_LONG);
    //
    debugPrint("WmsStrotre Id ${wms_stroeId}");
    bool isDialogShow = false;

    if (pageno > 1) {
      isDialogShow = false;
    } else {
      isDialogShow = true;
      // EasyLoading.show();
      MyDialogs.showLoadingDialog(context);
    }

    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;

    try {
      var data = {
        "product_ids": "$key",
        "location_id": "$location_id",
        "wmsstoreid": "$wms_stroeId"
      };

      Response response = await _dio.post(Endpoints.beforeYourCheckout,
          cancelToken: cancelToken, options: Options(headers: data));
      final responseData = jsonDecode(response.toString());

      //log("GGAAGGG ${responseData}");

      if (responseData['success'] == false) {
        EasyLoading.dismiss();
        return "";
      }

      //ProductData productsModel = ProductData.fromJson(response.toString());

      if (isDialogShow) {
        isDialogShow = false;
        Navigator.pop(context);
      }
      // EasyLoading.dismiss();

      return response.toString();
    } catch (e) {
      if (isDialogShow) {
        isDialogShow = false;
        Navigator.pop(context);
      }
      return "";
    }
  }

  Future<String> getTopSellingProductHomeScreenFV1(
      BuildContext context, int pageno, Function finish) async {
    var wms_stroeId =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    // var store_code= await SharedPref.getStringPreference(Constants.STORE_CODE);
    // var store_id= await SharedPref.getStringPreference(Constants.STORE_ID);
    // var stroe_name=await  SharedPref.getStringPreference(Constants.STORE_Name);
    var location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // var lat= await SharedPref.getStringPreference(Constants.LOCATION_LAT);
    // var log=await  SharedPref.getStringPreference(Constants.LOCATION_LONG);
    //
    debugPrint("WmsStrotre Id ${wms_stroeId}");

    // pageno=pageno+1;
    if (pageno > 1) {
    } else {
      // MyDialogs.showLoadingDialog(context);
    }

    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;

    try {
      var data = {
        "location_id": "$location_id",
        "wmsstoreid": "$wms_stroeId",
        "page_no": 1,
        "array_page_no": pageno,
      };

      debugPrint("DATAHOMEPAGE API ${data}");
      var stopwatch = Stopwatch();
      stopwatch.start();
      Response response = await _dio.get(
        Endpoints.getTopSellingProductHomeScreenFV1,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            "location_id": "$location_id",
            "wmsstoreid": "$wms_stroeId",
            "page_no": 1,
            "array_page_no": pageno,
          },
        ),
      );
      print("ELAPSED TIME ${stopwatch.elapsedMilliseconds}");
      final responseData = jsonDecode(response.toString());
      print("ELAPSED TIME 2 ${stopwatch.elapsedMilliseconds}");
      //log("GGAAGGG ${responseData}");
      log("getTopSellingProductHomeScreenFV1 Empty**** ${responseData}");

      if (responseData['success'] == false) {
        debugPrint("getTopSellingProductHomeScreenFV1 Empty**** ");
        finish();

        if (pageno > 1) {
        } else {
          //Navigator.pop(context);
        }
        return "";
      }

      //ProductData productsModel = ProductData.fromJson(response.toString());
      if (pageno > 1) {
      } else {
        //  Navigator.pop(context);
      }

      return response.toString();
    } catch (e) {
      if (pageno > 1) {
      } else {
        //Navigator.pop(context);
      }
      cancelToken.cancel('Logged out');
      cancelToken = CancelToken();
      return "";
    }
  }

  Future<String> getbeforeYourCheckoutPagination(
      String key, int pageno, String type_id) async {
    var wms_stroeId =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    // var store_code= await SharedPref.getStringPreference(Constants.STORE_CODE);
    // var store_id= await SharedPref.getStringPreference(Constants.STORE_ID);
    // var stroe_name=await  SharedPref.getStringPreference(Constants.STORE_Name);
    var location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // var lat= await SharedPref.getStringPreference(Constants.LOCATION_LAT);
    // var log=await  SharedPref.getStringPreference(Constants.LOCATION_LONG);
    //
    debugPrint("WmsStrotre Id ${wms_stroeId}");

    if (pageno > 1) {
    } else {
      EasyLoading.show();
    }

    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;

    try {
      var data = {
        "product_ids": "$key",
        "location_id": "$location_id",
        "wmsstoreid": "$wms_stroeId",
        "type_id": "$type_id"
      };

      Response response = await _dio.post(
          "${Endpoints.getProductPagination}&type_id=${type_id}&page_no=${pageno}",
          cancelToken: cancelToken,
          options: Options(headers: data));
      final responseData = jsonDecode(response.toString());

      //log("GGAAGGG ${responseData}");

      // if (responseData['success'] == false) {
      //   EasyLoading.dismiss();
      //   return "";
      // }

      //ProductData productsModel = ProductData.fromJson(response.toString());

      EasyLoading.dismiss();

      return response.toString();
    } catch (e) {
      EasyLoading.dismiss();
      return "";
    }
  }

  Future<String> getHomeProductPagination(int pageno, String url) async {
    debugPrint("getHomeProductPagination $pageno");
    var wms_stroeId =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    var store_code = await SharedPref.getStringPreference(Constants.STORE_CODE);
    //var store_id= await SharedPref.getStringPreference(Constants.STORE_ID);
    // var stroe_name=await  SharedPref.getStringPreference(Constants.STORE_Name);
    var location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // var lat= await SharedPref.getStringPreference(Constants.LOCATION_LAT);
    // var log=await  SharedPref.getStringPreference(Constants.LOCATION_LONG);
    //
    debugPrint("WmsStrotre Id ${wms_stroeId}");

    if (pageno > 1) {
    } else {
      EasyLoading.show();
    }

    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;

    try {
      String newUrl = "";
      if (url.endsWith("/")) {
        newUrl = "$url$pageno";
      } else {
        newUrl = "$url&page_no=$pageno";
      }
      Response response = await _dio.get(
        "$newUrl",
        cancelToken: cancelToken,
        options: Options(headers: {
          "search_item": "0",
          "customer_id": "",
          "wmsstoreid": "$wms_stroeId",
          "storecode": "$store_code",
          "location_id": "$location_id",
          "device_type": Platform.isAndroid ? "android" : "ios",
        }),
      );
      final responseData = jsonDecode(response.toString());

      //log("GGAAGGG ${responseData}");

      // if (responseData['success'] == false) {
      //   EasyLoading.dismiss();
      //   return "";
      // }

      //ProductData productsModel = ProductData.fromJson(response.toString());

      EasyLoading.dismiss();

      return response.toString();
    } catch (e) {
      EasyLoading.dismiss();
      cancelToken.cancel('Logged out');
      cancelToken = CancelToken();
      return "";
    }
  }

  Future<String> getBannerProducts(String key) async {
    // EasyLoading.show();

    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    Dio _dio = await DioFactory().getDio();
    ProductsModel? productsModel;
    try {
      var url = Endpoints.getBannerProducts + "/" + key + "/2/1";
      Response response = await _dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            "ondoor_app_code": Endpoints.AppVersionCode,
            'wmsstoreid': '$wms_store_id',
            'storename': '$store_name',
            'device_type': Platform.isAndroid ? "android" : "ios",
            'customer_id': '',
            'storeid': '$store_id',
            'location_id': '$location_id',
            'storecode': '$store_code',
            'Authorization': ''
          },
        ),
      );
      final responseData = jsonDecode(response.toString());
      if (responseData['success'] == false) {
        // EasyLoading.dismiss();
        return response.toString();
      }

      ProductsModel productsModel = ProductsModel.fromJson(response.toString());
      EasyLoading.dismiss();

      return response.toString();
    } catch (e) {
      EasyLoading.dismiss();
      return "";
    }
  }

  Future<CreditRequestModel?> checkCreditRequest(Function callback) async {
    Dio _dio = await DioFactory().getDio();
    try {
      // String coustomerId = "2358892";
      // String token ="Bearer efd1bf826e66086b1edf4add6131a3b0734db745";

      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);

      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";

      debugPrint("Token credit request $token ${access_token == ""}");
      //var data = json.encode({"location_id": "$location_id", "customer_id": coustomerId});
      var data = json.encode({"customer_id": coustomerId});
      var header = {
        'Authorization': token,
      };
      var url = "";
      debugPrint("Token credit request $token $data");
      if (access_token == "") {
        url = Endpoints.checkCreditRequestwithoutLogin;
        header = {'Authorization': token, 'location_id': location_id};
      } else {
        url = Endpoints.checkCreditRequest;
        header = {'Authorization': token, 'location_id': location_id};
      }
      debugPrint("Url credit request $url");
      Response response = await _dio.post(
        url,
        data: data,
        cancelToken: cancelToken,
        options: Options(
          headers: header,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data.toString().contains("statusCode") ||
            response.data.toString().isEmpty) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
        }
        CreditRequestModel model =
            CreditRequestModel.fromJson(response.toString());
        return model;
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
    }
  }

  Future<CheckCreditWithoutLoginResponse> checkCreditRequestWithoutLogin(
      String location_id, String store_code, String wmsStoreId) async {
    Dio dio = await DioFactory().getDio();
    var data = {
      "location_id": location_id,
      "Content-Type": "application/json",
      "device_type": Platform.isAndroid ? "android" : "ios",
      "storecode": store_code,
      "wmsstoreid": wmsStoreId
    };
    dio.options.headers = data;
    try {
      Response response = await dio.get(Endpoints.checkCreditRequestEndpoint);
      CheckCreditWithoutLoginResponse checkCreditWithoutLoginResponse =
          CheckCreditWithoutLoginResponse.fromJson(json.decode(response.data));
      return checkCreditWithoutLoginResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return CheckCreditWithoutLoginResponse(
        success: false,
      );
    }
  }

  Future<ShippingCharge?> getShippingCharges(
      double price, offer_totoal_price, Function callback) async {
    ShippingCharge shippingCharge = ShippingCharge();
    // EasyLoading.show();
    String locatioId =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String customerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String storeid = await SharedPref.getStringPreference(Constants.STORE_ID);
    String storecode =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String storeName =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wmsstoreid =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);

    String token = "$token_type $access_token";

    var data = json.encode({
      "price": price,
      "order_offer_total": offer_totoal_price,
      "location_id": locatioId,
      "customer_id": customerId,
      "device_type": Platform.isAndroid ? "android" : "ios",
      "seller_product": "0"
    });
    debugPrint("Shipping charge body ${data}");
    Response response = await _dio.post(
      Endpoints.shippingCharges,
      data: data,
      cancelToken: cancelToken,
      options: Options(
        preserveHeaderCase: true,
        headers: {
          'Authorization': token,
          "ondoor_app_code": Endpoints.AppVersionCode,
          "storecode": storecode,
          "location_id": locatioId,
          "storeid": storeid,
          "customer_id": customerId,
          "device_type": Platform.isAndroid ? "android" : "ios",
          "storename": storeName,
          "wmsstoreid": wmsstoreid,
        },
      ),
    );
    if (response.statusCode == 200) {
      if (response.data.toString().contains("statusCode")) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        shippingCharge = ShippingCharge();
      }
      shippingCharge = ShippingCharge.fromJson(response.toString());
    } else {
      shippingCharge = ShippingCharge(
          success: false,
          data: "",
          currentRewardBalance: "",
          currentWalletBalance: "",
          daysAllowedForCalendar: "",
          paymentGetway: <PaymentGetway>[],
          rewardMinimumAmount: "",
          showCoupon: 0);
    }
    // EasyLoading.dismiss();
    return shippingCharge;
  }

  Future<String?> productValidation(List<ProductUnit> cartitesmList,
      BuildContext context, Function callback) async {
    log("cartItems validation ${cartitesmList[0].toJson()}");
    Dio _dio = await DioFactory().getDio();
    try {
      MyDialogs.showLoadingDialog(context);

      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      String store_id =
          await SharedPref.getStringPreference(Constants.STORE_ID);
      String store_code =
          await SharedPref.getStringPreference(Constants.STORE_CODE);
      String store_name =
          await SharedPref.getStringPreference(Constants.STORE_Name);
      String wms_store_id =
          await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
      debugPrint("productValidation new" " ${store_id} ${store_code}");

      String token = "$token_type $access_token";

      List<CartJsonModel> listcartjson = [];
      double subtotalshow = 0;
      double subtotalcross = 0;

      int index = 0;

      var jsonData;
      int subproductTotalQuanitiy = 0;

      log("final cartitesmList ${jsonEncode(cartitesmList)}");
      for (var cartitem in cartitesmList) {
        index++;
        log("final cartitesmList ${cartitem.sortPrice}");
        var sortPrice = (double.parse(cartitem.sortPrice == null ||
                        cartitem.sortPrice == "null" ||
                        cartitem.sortPrice == ""
                    ? "0.0"
                    : cartitem.sortPrice!) *
                cartitem.addQuantity)
            .toString();
        var specialPrice = (double.parse(cartitem.specialPrice == null ||
                        cartitem.specialPrice == "null" ||
                        cartitem.specialPrice == ""
                    ? "0.0"
                    : cartitem.specialPrice!) *
                cartitem.addQuantity)
            .toString();
        var price = (double.parse(cartitem.price == null || cartitem.price == ""
                    ? "0.0"
                    : cartitem.price!) *
                cartitem.addQuantity)
            .toString();
        var crossprice = cartitem.specialPrice == ""
            ? "₹ ${double.parse(price).toStringAsFixed(2)}"
            : "₹ ${double.parse(price).toStringAsFixed(2)}";
        var showprice = cartitem.specialPrice == ""
            ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
            : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

        subtotalshow =
            subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
        subtotalcross =
            subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));

        CartJsonModel cartJsonModel = CartJsonModel();

        cartJsonModel.index = index.toString();
        cartJsonModel.productId = cartitem.productId;
        cartJsonModel.name = cartitem.name;
        cartJsonModel.qty = cartitem.addQuantity.toString();
        cartJsonModel.image = cartitem.image;
        cartJsonModel.model = cartitem.model;
        cartJsonModel.subtract = cartitem.subtract;
        cartJsonModel.discountLabel = cartitem.discountLabel;
        cartJsonModel.discountText = cartitem.discountText;
        cartJsonModel.cOfferId = cartitem.cOfferId.toString();
        cartJsonModel.offerType = cartitem.cOfferType.toString();
        cartJsonModel.subProduct = cartitem.subProduct;
        cartJsonModel.price = double.parse(cartitem.sortPrice == null ||
                cartitem.sortPrice == "null" ||
                cartitem.sortPrice == ""
            ? "0.0"
            : cartitem.sortPrice!);
        cartJsonModel.option = cartitem.options;
        cartJsonModel.locationId = location_id.toString();
        cartJsonModel.shippingOption =
            cartitem.shippingOptions as ShippingOption?;

        if (cartitem.subProduct != null) {
          cartJsonModel.subProductOfferId = cartitem.subProduct!.offerProductId;
        }
        if (cartitem.subProduct != null) {
          log("Add Quantity is zero");
          subproductTotalQuanitiy =
              subproductTotalQuanitiy + cartitem.addQuantity;

          log("Add Quantity is ${cartitem.subProduct!.buyQty}");
        }

        listcartjson.add(cartJsonModel);
      }

      log("final model ${jsonEncode(listcartjson)}");
      Map finaldata = Map();
      finaldata = {
        "data": listcartjson,
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };
      // finaldata["data"] = listcartjson;

      var data2 = json.encode({
        "data": listcartjson == null
            ? []
            : List<dynamic>.from(listcartjson!.map((x) => x.toMap())),
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      });

      debugPrint("Input >>>>>>>${data2}");

      var data3 = {
        "data": listcartjson == null
            ? []
            : List<dynamic>.from(listcartjson!.map((x) => x.toMap())),
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };

      log("Input 1 ${json.encode(data3)}");
      log("Input 2 ${data3}");

      Response response = await _dio.post(
        Endpoints.productValidation,
        data: json.encode(data3),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': "$token",
            "ondoor_app_code": Endpoints.AppVersionCode,
            'wmsstoreid': '$wms_store_id',
            'storename': '$store_name',
            'device_type': Platform.isAndroid ? "android" : "ios",
            'customer_id': '$coustomerId',
            'storeid': '$store_id',
            'location_id': "$location_id",
            'storecode': '$store_code'
          },
        ),
      );
      debugPrint("Output >>>>>>>${response.toString()}");
      if (response.statusCode == 200) {
        //  EasyLoading.dismiss();
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
        }

        Navigator.pop(context);
        // CreditRequestModel model =
        // CreditRequestModel.fromJson(response.toString());
        return response.toString();
      }
    } catch (error, stacktrace) {
      // EasyLoading.dismiss();
      Navigator.pop(context);
      print("Product Validation error ${error}");
      print("Product Validation trace ${stacktrace}");
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "";
      }
      return message;
    }
  }

  Future<String?> productValidationForOrderModification(
      List<ProductUnit> cartitesmList,
      String order_id,
      BuildContext context,
      Function callback) async {
    log("cartItems validation ${cartitesmList[0].toJson()}");
    Dio _dio = await DioFactory().getDio();
    try {
      MyDialogs.showLoadingDialog(context);

      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      String store_id =
          await SharedPref.getStringPreference(Constants.STORE_ID);
      String store_code =
          await SharedPref.getStringPreference(Constants.STORE_CODE);
      String store_name =
          await SharedPref.getStringPreference(Constants.STORE_Name);
      String wms_store_id =
          await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
      debugPrint("productValidation new" " ${store_id} ${store_code}");

      String token = "$token_type $access_token";

      List<Map<String, dynamic>> listcartjson = [];
      // double subtotalshow = 0;
      // double subtotalcross = 0;
      //
      // int index = 0;
      //
      // var jsonData;
      // int subproductTotalQuanitiy = 0;
      //
      // log("final cartitesmList ${jsonEncode(cartitesmList)}");
      // for (var cartitem in cartitesmList) {
      //   index++;
      //   var sortPrice = (double.parse(
      //               cartitem.sortPrice == null || cartitem.sortPrice == ""
      //                   ? "0.0"
      //                   : cartitem.sortPrice!) *
      //           cartitem.addQuantity)
      //       .toString();
      //   var specialPrice = (double.parse(
      //               cartitem.specialPrice == null || cartitem.specialPrice == ""
      //                   ? "0.0"
      //                   : cartitem.specialPrice!) *
      //           cartitem.addQuantity)
      //       .toString();
      //   var price = (double.parse(cartitem.price == null || cartitem.price == ""
      //               ? "0.0"
      //               : cartitem.price!) *
      //           cartitem.addQuantity)
      //       .toString();
      //   var crossprice = cartitem.specialPrice == ""
      //       ? "₹ ${double.parse(price).toStringAsFixed(2)}"
      //       : "₹ ${double.parse(price).toStringAsFixed(2)}";
      //   var showprice = cartitem.specialPrice == ""
      //       ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
      //       : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";
      //
      //   subtotalshow =
      //       subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
      //   subtotalcross =
      //       subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));
      //
      //   CartJsonModel cartJsonModel = CartJsonModel();
      //
      //   cartJsonModel.index = index.toString();
      //   cartJsonModel.productId = cartitem.productId;
      //   cartJsonModel.name = cartitem.name;
      //   cartJsonModel.qty = cartitem.addQuantity.toString();
      //   cartJsonModel.image = cartitem.image;
      //   cartJsonModel.model = cartitem.model;
      //   cartJsonModel.subtract = cartitem.subtract;
      //   cartJsonModel.discountLabel = cartitem.discountLabel;
      //   cartJsonModel.discountText = cartitem.discountText;
      //   cartJsonModel.cOfferId = cartitem.cOfferId.toString();
      //   cartJsonModel.offerType = cartitem.cOfferType.toString();
      //   cartJsonModel.subProduct = cartitem.subProduct;
      //   cartJsonModel.price = double.parse(
      //       cartitem.sortPrice == null || cartitem.sortPrice == ""
      //           ? "0.0"
      //           : cartitem.sortPrice!);
      //   cartJsonModel.option = cartitem.options;
      //   cartJsonModel.locationId = location_id.toString();
      //   cartJsonModel.shippingOption =
      //       cartitem.shippingOptions as ShippingOption?;
      //
      //   if (cartitem.subProduct != null) {
      //     cartJsonModel.subProductOfferId = cartitem.subProduct!.offerProductId;
      //   }
      //   if (cartitem.subProduct != null) {
      //     log("Add Quantity is zero");
      //     subproductTotalQuanitiy =
      //         subproductTotalQuanitiy + cartitem.addQuantity;
      //
      //     log("Add Quantity is ${cartitem.subProduct!.buyQty}");
      //   }
      //
      //   listcartjson.add(cartJsonModel);
      // }
      for (int i = 0; i < cartitesmList.length; i++) {
        var cartData = cartitesmList[i];
        listcartjson.add({
          "c_offer_id": cartData.cOfferId,
          "image": cartData.image,
          "index": i,
          "location_id": location_id,
          "model": cartData.model,
          "name": cartData.name,
          "offer_type": cartData.cOfferType,
          "option": cartData.options,
          "price": cartData.price,
          "product_id": cartData.productId,
          "qty": cartData.quantity,
          "shipping_option": cartData.shippingOptions,
          "sub_product": cartData.subProduct,
          "subtract": cartData.subtract
        });
      }
      listcartjson = listcartjson.toSet().toList();
      var data3 = {
        "data": listcartjson,
        "order_id": order_id,
        "order_total": "1",
        "ondoor_product": "1",
        "customer_id": coustomerId,
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };

      Response response = await _dio.post(
        Endpoints.productValidation,
        data: json.encode(data3),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': "$token",
            "ondoor_app_code": Endpoints.AppVersionCode,
            'wmsstoreid': '$wms_store_id',
            'storename': '$store_name',
            'device_type': Platform.isAndroid ? "android" : "ios",
            'customer_id': '$coustomerId',
            'storeid': '$store_id',
            'location_id': "$location_id",
            'storecode': '$store_code'
          },
        ),
      );
      debugPrint("Output >>>>>>>${response.toString()}");
      if (response.statusCode == 200) {
        //  EasyLoading.dismiss();
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
        }
        Navigator.pop(context);
        return response.toString();
      }
    } catch (error, stacktrace) {
      // EasyLoading.dismiss();
      Navigator.pop(context);
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "";
      }
      print("PRODUCT VALIDATION ERROR ${error}");
      print("PRODUCT VALIDATION TRACE ${stacktrace}");
      print("PRODUCT VALIDATION TRACE ${message}");
    }
  }

  Future<String?> productValidationcheckout(
      List<ProductUnit> cartitesmList,
      String store_id1,
      String store_name1,
      String wms_store_id1,
      String location_id1,
      String store_code1,
      Function callback) async {
    Dio _dio = await DioFactory().getDio();
    try {
      EasyLoading.show();

      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      String store_id =
          await SharedPref.getStringPreference(Constants.STORE_ID);
      String store_code =
          await SharedPref.getStringPreference(Constants.STORE_CODE);
      String store_name =
          await SharedPref.getStringPreference(Constants.STORE_Name);
      String wms_store_id =
          await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
      debugPrint("productValidation new"
          " ${store_id} ${store_code}");

      String token = "$token_type $access_token";

      List<CartJsonModel> listcartjson = [];
      double subtotalshow = 0;
      double subtotalcross = 0;

      int index = 0;

      var jsonData;
      int subproductTotalQuanitiy = 0;
      for (var cartitem in cartitesmList) {
        index++;
        var sortPrice = (double.parse(cartitem.sortPrice == null ||
                        cartitem.sortPrice == "null" ||
                        cartitem.sortPrice == ""
                    ? "0.0"
                    : cartitem.sortPrice!) *
                cartitem.addQuantity)
            .toString();
        var specialPrice = (double.parse(cartitem.specialPrice == null ||
                        cartitem.specialPrice == "null" ||
                        cartitem.specialPrice == "" ||
                        cartitem.specialPrice == "Free"
                    ? "0.0"
                    : cartitem.specialPrice.toString()) *
                cartitem.addQuantity)
            .toString();
        print("SPECIAL PRICE ${cartitem.specialPrice}");
        var price = (double.parse(cartitem.price == null || cartitem.price == ""
                    ? "0.0"
                    : cartitem.price!) *
                cartitem.addQuantity)
            .toString();
        var crossprice = cartitem.specialPrice == ""
            ? "₹ ${double.parse(price).toStringAsFixed(2)}"
            : "₹ ${double.parse(price).toStringAsFixed(2)}";
        var showprice = cartitem.specialPrice == ""
            ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
            : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

        subtotalshow =
            subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
        subtotalcross =
            subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));

        CartJsonModel cartJsonModel = CartJsonModel();

        cartJsonModel.index = index.toString();
        cartJsonModel.productId = cartitem.productId;
        cartJsonModel.name = cartitem.name;
        cartJsonModel.qty = cartitem.addQuantity.toString();
        cartJsonModel.image = cartitem.image;
        cartJsonModel.model = cartitem.model;
        cartJsonModel.subtract = cartitem.subtract;
        cartJsonModel.discountLabel = cartitem.discountLabel;
        cartJsonModel.discountText = cartitem.discountText;
        cartJsonModel.cOfferId = cartitem.cOfferId.toString();
        cartJsonModel.offerType = cartitem.cOfferType.toString();
        cartJsonModel.subProduct = cartitem.subProduct;
        cartJsonModel.price = double.parse(cartitem.sortPrice == null ||
                cartitem.sortPrice == "null" ||
                cartitem.sortPrice == ""
            ? "0.0"
            : cartitem.sortPrice!);
        cartJsonModel.option = cartitem.options;
        cartJsonModel.locationId = location_id.toString();
        // if(cartitem.shippingOptions!=null && cartitem.shippingOptions!.isNotEmpty){
        //   cartitem.shippingOptions!.map((e) {
        //     cartJsonModel.shippingOption=e;
        //   },);
        // }
        // commented by rohit not working in free product flow
        // cartJsonModel.shippingOption =
        //     cartitem.shippingOptions as ShippingOption?;

        if (cartitem.subProduct != null) {
          cartJsonModel.subProductOfferId = cartitem.subProduct!.offerProductId;
        }
        if (cartitem.subProduct != null) {
          log("Add Quantity is zero");
          subproductTotalQuanitiy =
              subproductTotalQuanitiy + cartitem.addQuantity;

          log("Add Quantity is ${cartitem.subProduct!.buyQty}");
        }

        listcartjson.add(cartJsonModel);
      }

      log("final model ${jsonEncode(listcartjson)}");
      Map finaldata = Map();
      finaldata = {
        "data": listcartjson,
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };
      // finaldata["data"] = listcartjson;

      var data2 = json.encode({
        "data": listcartjson == null
            ? []
            : List<dynamic>.from(listcartjson!.map((x) => x.toMap())),
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      });

      debugPrint("Input >>>>>>>${data2}");

      var data3 = {
        "data": listcartjson == null
            ? []
            : List<dynamic>.from(listcartjson!.map((x) => x.toMap())),
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };

      log("Input 1 ${json.encode(data3)}");
      log("Input 2 ${data3}");

      Response response = await _dio.post(
        Endpoints.productValidation,
        data: json.encode(data3),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': "$token",
            "ondoor_app_code": Endpoints.AppVersionCode,
            'wmsstoreid': '$wms_store_id1',
            'storename': '$store_name1',
            'device_type': Platform.isAndroid ? "android" : "ios",
            'customer_id': '$coustomerId',
            'storeid': '$store_id1',
            'location_id': "$location_id1",
            'storecode': '$store_code1'
          },
        ),
      );
      debugPrint("Output >>>>>>>${response.toString()}");
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
        }

        // CreditRequestModel model =
        // CreditRequestModel.fromJson(response.toString());
        return response.toString();
      }
    } catch (error, stacktrace) {
      print("Product Validation Error ${error}");
      print("Product Validation STackTrace ${stacktrace}");
      EasyLoading.dismiss();
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "";
      }
    }
  }

  Future<PaytmChecksumresponse> getValidateCheckSum(
      input, Function callback) async {
    try {
      String tokentype =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String accesstoken =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$tokentype $accesstoken";
      Response response = await _dio.post(
        Endpoints.PAYTM_CHECkSUM_URL,
        data: input,
        cancelToken: cancelToken,
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': token,
            "ondoor_app_code": Endpoints.AppVersionCode,
          },
        ),
      );
      PaytmChecksumresponse ch;
      if (response.data != null && response.data.isNotEmpty) {
        debugPrint("cmfres :" + response.data.toString());
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
        }

        // Check the response format
        // Parse the string into a Map<String, dynamic>
        Map<String, dynamic> responseMap = jsonDecode(response.data);
        ch = PaytmChecksumresponse.fromJson(responseMap);
      } else {
        ch = PaytmChecksumresponse(success: false);
        print('Error: Response data is null or empty.');
      }
      debugPrint("i am here: res ${response.toString()}");
      // Checksumresponse ch = Checksumresponse.fromJson(response.data);
      // debugPrint("i am here: res $ch");
      return ch;
    } catch (error, stack) {
      debugPrint("i am here: error $error stack ${stack}");
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Please try again later!";
      }
      return PaytmChecksumresponse(success: false, message: message);
    }
  }

  Future<OrderbyOrderIdResponse> getOrderbyOrderId(
      {required String orderId, required Function callback}) async {
    try {
      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      var body = {"order_id": orderId, "location_id": location_id};
      String token = "$token_type $access_token";
      Response response = await _dio.post("${Endpoints.getOrderByOrderId}",
          data: body,
          cancelToken: cancelToken,
          options: Options(
            preserveHeaderCase: true,
            headers: {'Authorization': token},
          ));
      if (response.data.toString().contains("statusCode")) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
        return OrderbyOrderIdResponse(success: false, data: OrderData());
      } else {
        OrderbyOrderIdResponse orderbyOrderIdResponse =
            OrderbyOrderIdResponse.fromJson(response.data);

        return orderbyOrderIdResponse;
      }
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return OrderbyOrderIdResponse(success: false, data: OrderData());
    }
  }

  Future<String?> locationproductValidation(
      List<ProductUnit> cartitesmList,
      String store_id1,
      String store_name1,
      String wms_store_id1,
      String location_id1,
      String store_code1,
      Function callback) async {
    log("cartItems validation ${cartitesmList[0].toJson()}");
    Dio _dio = await DioFactory().getDio();
    try {
      EasyLoading.show();

      String location_id =
          await SharedPref.getStringPreference(Constants.LOCATION_ID);
      String coustomerId =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
      String store_id =
          await SharedPref.getStringPreference(Constants.STORE_ID);
      String store_code =
          await SharedPref.getStringPreference(Constants.STORE_CODE);
      String store_name =
          await SharedPref.getStringPreference(Constants.STORE_Name);
      String wms_store_id =
          await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
      debugPrint("productValidation new"
          " ${store_id} ${store_code}");

      String token = "$token_type $access_token";

      List<CartJsonModel> listcartjson = [];
      double subtotalshow = 0;
      double subtotalcross = 0;

      int index = 0;

      var jsonData;
      int subproductTotalQuanitiy = 0;
      for (var cartitem in cartitesmList) {
        index++;
        var sortPrice = (double.parse(cartitem.sortPrice == null ||
                        cartitem.sortPrice == "null" ||
                        cartitem.sortPrice == ""
                    ? "0.0"
                    : cartitem.sortPrice!) *
                cartitem.addQuantity)
            .toString();
        var specialPrice = (double.parse(cartitem.specialPrice == null ||
                        cartitem.specialPrice == "null" ||
                        cartitem.specialPrice == "" ||
                        cartitem.specialPrice == "Free"
                    ? "0.0"
                    : cartitem.specialPrice.toString()) *
                cartitem.addQuantity)
            .toString();
        var price = (double.parse(cartitem.price == null ||
                        cartitem.price == "null" ||
                        cartitem.price == ""
                    ? "0.0"
                    : cartitem.price!) *
                cartitem.addQuantity)
            .toString();
        var crossprice = cartitem.specialPrice == ""
            ? "₹ ${double.parse(price).toStringAsFixed(2)}"
            : "₹ ${double.parse(price).toStringAsFixed(2)}";
        var showprice = cartitem.specialPrice == ""
            ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
            : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

        subtotalshow =
            subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
        subtotalcross =
            subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));

        CartJsonModel cartJsonModel = CartJsonModel();

        cartJsonModel.index = index.toString();
        cartJsonModel.productId = cartitem.productId;
        cartJsonModel.name = cartitem.name;
        cartJsonModel.qty = cartitem.addQuantity.toString();
        cartJsonModel.image = cartitem.image;
        cartJsonModel.model = cartitem.model;
        cartJsonModel.subtract = cartitem.subtract;
        cartJsonModel.discountLabel = cartitem.discountLabel;
        cartJsonModel.discountText = cartitem.discountText;
        cartJsonModel.cOfferId = cartitem.cOfferId.toString();
        cartJsonModel.offerType = cartitem.cOfferType.toString();
        cartJsonModel.subProduct = cartitem.subProduct;
        cartJsonModel.price = double.parse(cartitem.sortPrice == null ||
                cartitem.sortPrice == "null" ||
                cartitem.sortPrice == ""
            ? "0.0"
            : cartitem.sortPrice!);
        cartJsonModel.option = cartitem.options;
        cartJsonModel.locationId = location_id.toString();
        // commented by rohit not working in free product flow
        // print("SHIPPING OPTIONS LIST ${cartitem.shippingOptions}");
        // cartJsonModel.shippingOption =
        //     cartitem.shippingOptions as ShippingOption?;

        if (cartitem.subProduct != null) {
          cartJsonModel.subProductOfferId = cartitem.subProduct!.offerProductId;
        }
        if (cartitem.subProduct != null) {
          log("Add Quantity is zero");
          subproductTotalQuanitiy =
              subproductTotalQuanitiy + cartitem.addQuantity;

          log("Add Quantity is ${cartitem.subProduct!.buyQty}");
        }

        listcartjson.add(cartJsonModel);
      }

      log("final model ${jsonEncode(listcartjson)}");
      Map finaldata = Map();
      finaldata = {
        "data": listcartjson,
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };
      // finaldata["data"] = listcartjson;

      var data2 = json.encode({
        "data": listcartjson == null
            ? []
            : List<dynamic>.from(listcartjson!.map((x) => x.toMap())),
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      });

      debugPrint("Input >>>>>>>${data2}");

      var data3 = {
        "data": listcartjson == null
            ? []
            : List<dynamic>.from(listcartjson!.map((x) => x.toMap())),
        "order_total": "$subtotalshow",
        "ondoor_product": "1",
        "customer_id": "$coustomerId",
        "old_promo_wallet_used": "0",
        "campaign_id": "0",
        "is_edit": "0"
      };
      var headers = {
        'Authorization': "$token",
        "ondoor_app_code": Endpoints.AppVersionCode,
        'wmsstoreid': '$wms_store_id1',
        'storename': '$store_name1',
        'device_type': Platform.isAndroid ? "android" : "ios",
        'customer_id': '$coustomerId',
        'storeid': '$store_id1',
        'location_id': "$location_id1",
        'storecode': '$store_code1'
      };
      log("Input 1 ${json.encode(data3)}");
      log("Input 2 ${data3}");
      log("Input 3 ${headers}");

      Response response = await _dio.post(
        Endpoints.locationProductValidation,
        data: json.encode(data3),
        cancelToken: cancelToken,
        options: Options(headers: headers),
      );
      debugPrint("Output >>>>>>>${response.toString()}");
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
          return "";
        } else {
          return response.toString();
        }

        // CreditRequestModel model =
        // CreditRequestModel.fromJson(response.toString());
      }
    } catch (error, stacktrace) {
      print("LOCATION VALIDATION ERROR ${error}");
      print("LOCATION STACKTRACE ${stacktrace}");
      EasyLoading.dismiss();
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "";
      }
    }
  }

  Future<dynamic> cartitemnjson(List<ProductUnit> cartitesmList) async {
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    List<CartJsonModel> listcartjson = [];
    double subtotalshow = 0;
    double subtotalcross = 0;

    int index = 0;

    var jsonData;
    for (var cartitem in cartitesmList) {
      index++;
      var sortPrice = (double.parse(
                  cartitem.sortPrice == null || cartitem.sortPrice == ""
                      ? "0.0"
                      : cartitem.sortPrice!) *
              cartitem.addQuantity)
          .toString();
      var specialPrice = (double.parse(
                  cartitem.specialPrice == null || cartitem.specialPrice == ""
                      ? "0.0"
                      : cartitem.specialPrice!) *
              cartitem.addQuantity)
          .toString();
      var price = (double.parse(cartitem.price == null || cartitem.price == ""
                  ? "0.0"
                  : cartitem.price!) *
              cartitem.addQuantity)
          .toString();
      var crossprice = cartitem.specialPrice == ""
          ? "₹ ${double.parse(price).toStringAsFixed(2)}"
          : "₹ ${double.parse(price).toStringAsFixed(2)}";
      var showprice = cartitem.specialPrice == ""
          ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

      subtotalshow =
          subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
      subtotalcross =
          subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));

      CartJsonModel cartJsonModel = CartJsonModel();

      cartJsonModel.index = index.toString();
      cartJsonModel.productId = cartitem.productId;
      cartJsonModel.name = cartitem.name;
      cartJsonModel.qty = cartitem.quantity;
      cartJsonModel.image = cartitem.image;
      cartJsonModel.model = cartitem.model;
      cartJsonModel.subtract = cartitem.subtract;
      cartJsonModel.discountLabel = cartitem.discountLabel;
      cartJsonModel.discountText = cartitem.discountText;
      cartJsonModel.cOfferId = cartitem.cOfferId.toString();
      cartJsonModel.offerType = cartitem.cOfferType.toString();
      cartJsonModel.subProduct = cartitem.subProduct;
      cartJsonModel.price = double.parse(cartitem.price! ?? "0");
      cartJsonModel.option = cartitem.options;
      cartJsonModel.locationId = location_id.toString();
      cartJsonModel.shippingOption =
          cartitem.shippingOptions as ShippingOption?;

      log("SybProduct Gaurav ${cartitem.subProduct}");

      //if(cartitem.subProduct!=null)
      //  {
      cartJsonModel.subProductOfferId = cartitem.subProduct!.offerProductId;
      //  }
      listcartjson.add(cartJsonModel);
    }

    var list = json.encode(cartitesmList);
    jsonData = {
      //"data": cartitesmList,
      "order_total": "$subtotalshow",
      "ondoor_product": "1",
      "customer_id": "$coustomerId",
      "old_promo_wallet_used": "0",
      "campaign_id": "0",
      "is_edit": "0"
    };

    print("CARTITEM JSON  ${list}");
    print("CARTITEM JSON  ${jsonEncode(jsonData)}");

    return listcartjson;
  }

  Future<CheckSumResponse?> generateChecksumupiApi(
      String orderId, String amount, Function callback) async {
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);

    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    String token = "$token_type $access_token";
    var data = {
      "order_id": "${orderId}",
      "customer_id": "$coustomerId",
      "amount": "${amount}",
      "paytm_type": "paytmupi"
    };
    var headers = {
      'Authorization': "$token",
      "ondoor_app_code": Endpoints.AppVersionCode,
      'wmsstoreid': '$wms_store_id',
      'storename': '$store_name',
      'device_type': Platform.isAndroid ? "android" : "ios",
      'customer_id': '$coustomerId',
      'storeid': '$store_id',
      'location_id': "$location_id",
      'storecode': '$store_code'
    };
    try {
      Response response = await _dio.post(Endpoints.generateChecksumupi,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));
      if (response.data.toString().contains("statusCode")) {
        print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
        var data = jsonDecode(response.data);
        int statuscode = data['statusCode'];
        String statusText = data['statusText'];
        print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

        if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
          SessionExpire(
              navigationService.navigatorKey.currentContext!, callback);
        }
      }
      CheckSumResponse checkSumResponse =
          checkSumResponseFromJson(response.data.toString());
      return checkSumResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return null;
    }
  }

  Future<CheckOnlinePaymentResponse> checkOnlinePayment(
      String orderId, Function callback) async {
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);

    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    String token = "$token_type $access_token";
    var data = {
      "order_id": "${orderId}",
      "customer_id": "$coustomerId",
    };
    var headers = {
      'Authorization': "$token",
      "ondoor_app_code": Endpoints.AppVersionCode,
      'wmsstoreid': '$wms_store_id',
      'storename': '$store_name',
      'device_type': Platform.isAndroid ? "android" : "ios",
      'customer_id': '$coustomerId',
      'storeid': '$store_id',
      'location_id': "$location_id",
      'storecode': '$store_code'
    };
    try {
      Response response = await _dio.post(Endpoints.checkOnlinePayment,
          data: data,
          cancelToken: cancelToken,
          options: Options(headers: headers));

      print("checkOnlinePaymentG ${response.statusCode}");
      print("checkOnlinePaymentG ${response.data.toString()}");
      if (response.statusCode == 200) {
        if (response.data.toString().contains("error")) {
          return CheckOnlinePaymentResponse(
              message: response.data["error"], success: false);
        }
        if (response.data.toString().contains("statusCode")) {
          print("RESPONSE DATA ${response.data} ${response.data.runtimeType}");
          var data = jsonDecode(response.data);
          int statuscode = data['statusCode'];
          String statusText = data['statusText'];
          print("STATUS TEXT ${statusText} STATUS CODE  ${statuscode}");

          if (statuscode.toString() == "401" && token.trim().isNotEmpty) {
            SessionExpire(
                navigationService.navigatorKey.currentContext!, callback);
          }
          return CheckOnlinePaymentResponse(success: false, message: "");
        } else {
          CheckOnlinePaymentResponse data =
              checkOnlinePaymentResponseFromJson(response.data);

          return data;
        }
      } else {
        return CheckOnlinePaymentResponse(
            success: false, message: response.data["error"]);
      }
      CheckSumResponse checkSumResponse =
          checkSumResponseFromJson(response.data.toString());
      // return checkSumResponse;
    } catch (error, stacktrace) {
      String message = "";
      if (error is DioException) {
        ServerError e = ServerError.withError(error: error);
        message = e.getErrorMessage();
      } else {
        message = "Something Went wrong";
      }
      debugPrint("Exception occurred: $message stackTrace: $stacktrace");
      return CheckOnlinePaymentResponse(message: message);
    }
  }
}

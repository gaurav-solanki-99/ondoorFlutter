import 'package:dio/dio.dart';

class ServerError implements Exception {
  int? _errorCode = 200;
  String _errorMessage = "";

  ServerError.withError({required DioException? error}) {
    _handleError(error!);
  }

  getErrorCode() {
    return _errorCode;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  _handleError(DioException error) async {
    _errorCode = error.response!.statusCode!;

    switch (error.type) {
      case DioExceptionType.cancel:
        // _errorMessage = "request_was_cancelled_key".tr();
        break;
      case DioExceptionType.connectionTimeout:
        // _errorMessage = "connection_timeout_key".tr();
        break;
      case DioExceptionType.unknown:
        _errorMessage = "connection_failed_due_to_internet_connection_key";
        break;
      case DioExceptionType.receiveTimeout:
        _errorMessage = "Receive timeout in connection";
        break;
      case DioExceptionType.badResponse:
        if (error.response!.statusCode == 401) {
          _errorMessage = error.response!.statusMessage!;
        }
        if (error.response!.statusCode == 404) {
          // handle 404 here
        }
        if (error.response!.statusCode == 202) {
          // 202
        }
        if (error.response!.statusCode == 429) {
          // Fluttertoast.showToast(
          //     msg:
          //         "Network congestion error.. Please try again after some time.",
          //     backgroundColor: ColorPrimary);
        }
        if (error.response!.statusCode == 500) {
          // Fluttertoast.showToast(
          //     msg: "Something went wrong. Please try again after some time.",
          //     backgroundColor: ColorPrimary);
          // animatedAlertDilog();
          //resetapp();
        }
        if (error.response!.statusCode == 502) {
          // print("come here-->");
          // Fluttertoast.showToast(
          //     msg:
          //         "Network congestion error.. Please try again after some time.",
          //     backgroundColor: ColorPrimary);
        }
        if (error.response!.statusCode == 503) {
          // print("come here-->");
          // Fluttertoast.showToast(
          //     msg:
          //         "The server is currently unavailable. Please try again after some time.",
          //     backgroundColor: ColorPrimary);
        }
        if (error.response!.statusCode == 504) {
          // print("come here-->");
          // Fluttertoast.showToast(
          //     msg: "Gateway timeout. Please try again after some time.",
          //     backgroundColor: ColorPrimary);
        }
        break;

      case DioExceptionType.sendTimeout:
        _errorMessage = "Receive timeout in send request";
        break;
      case DioExceptionType.badCertificate:
      // TODO: Handle this case.
      case DioExceptionType.connectionError:
      // TODO: Handle this case.
    }
    return _errorMessage;
  }
}

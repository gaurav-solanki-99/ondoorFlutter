import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/models/notification_list_response.dart';
import 'package:ondoor/screens/notification_screen/notification_bloc/notification_list_event.dart';
import 'package:ondoor/screens/notification_screen/notification_bloc/notification_list_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

class NotificationListBloc
    extends Bloc<NotificationListEvent, NotificationListState> {
  List<NotificationData> notificationList = [];
  NotificationListResponse notificationListResponse =
      NotificationListResponse();
  NotificationListBloc() : super(NotificationListInitialState()) {
    on<NotificationListInitialEvent>(
        (event, emit) => emit(NotificationListInitialState()));
    on<NotificationViewMoreEvent>(
      (event, emit) {
        emit(NotificationListLoadingState());
        emit(NotificationViewMoreState(
            notificationList: event.notificationList));
      },
    );
    on<NotificationListLoadingEvent>(
        (event, emit) => emit(NotificationListLoadingState()));
    on<NotificationListLoadedEvent>((event, emit) => emit(
        NotificationListLoadedState(notificationList: event.notificationList)));
  }
  void callNotificationListApi(context) async {
    if (await Network.isConnected()) {
      add(NotificationListLoadingEvent());
      notificationListResponse =
          await ApiProvider().getnotificationList(() async {
        callNotificationListApi(context);
      });
      if (notificationListResponse.success == true) {
        notificationList = notificationListResponse.data!;
        add(NotificationListLoadedEvent(notificationList: notificationList));
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        callNotificationListApi(context);
      });
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:ondoor/models/notification_list_response.dart';

class NotificationListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationListInitialState extends NotificationListState {
  @override
  List<Object?> get props => [];
}

class NotificationListLoadingState extends NotificationListState {
  @override
  List<Object?> get props => [];
}

class NotificationViewMoreState extends NotificationListState {
  List<NotificationData> notificationList;
  NotificationViewMoreState({required this.notificationList});
  @override
  List<Object?> get props => [notificationList];
}

class NotificationListLoadedState extends NotificationListState {
  List<NotificationData> notificationList;
  NotificationListLoadedState({required this.notificationList});
  @override
  List<Object?> get props => [notificationList];
}

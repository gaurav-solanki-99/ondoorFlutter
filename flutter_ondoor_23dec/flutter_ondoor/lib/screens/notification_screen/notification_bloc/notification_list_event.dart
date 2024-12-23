import 'package:equatable/equatable.dart';
import 'package:ondoor/models/notification_list_response.dart';

class NotificationListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationListInitialEvent extends NotificationListEvent {
  @override
  List<Object?> get props => [];
}

class NotificationListLoadingEvent extends NotificationListEvent {
  @override
  List<Object?> get props => [];
}

class NotificationViewMoreEvent extends NotificationListEvent {
  List<NotificationData> notificationList;
  NotificationViewMoreEvent({required this.notificationList});
  @override
  List<Object?> get props => [notificationList];
}

class NotificationListLoadedEvent extends NotificationListEvent {
  List<NotificationData> notificationList;
  NotificationListLoadedEvent({required this.notificationList});
  @override
  List<Object?> get props => [notificationList];
}

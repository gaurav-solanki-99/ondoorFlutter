import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LoginWidgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginWidgetInitialEvent extends LoginWidgetEvent {
  @override
  List<Object?> get props => [];
}

class LoginWidgetFocusEvent extends LoginWidgetEvent {
  FocusNode focusNode;
  @override
  List<Object?> get props => [focusNode];
  LoginWidgetFocusEvent({required this.focusNode});
}

class LoginWidgetPageChangeEvent extends LoginWidgetEvent {
  int pageIndex;
  @override
  List<Object?> get props => [pageIndex];
  LoginWidgetPageChangeEvent({required this.pageIndex});
}

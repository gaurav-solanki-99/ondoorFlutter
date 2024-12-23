import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class LoginWidgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginWidgetInitialState extends LoginWidgetState {
  @override
  List<Object?> get props => [];
}

class LoginWidgetFocusState extends LoginWidgetState {
  FocusNode focusNode;
  @override
  List<Object?> get props => [focusNode];
  LoginWidgetFocusState({required this.focusNode});
}

class LoginWidgetPageChangeState extends LoginWidgetState {
  int pageIndex;
  @override
  List<Object?> get props => [pageIndex];
  LoginWidgetPageChangeState({required this.pageIndex});
}

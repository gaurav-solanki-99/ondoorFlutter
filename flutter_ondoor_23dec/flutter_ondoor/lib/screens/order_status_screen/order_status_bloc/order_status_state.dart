import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

class OrderStatusState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderStatusInitialState extends OrderStatusState {
  @override
  List<Object?> get props => [];
}

class OrderStatusNullState extends OrderStatusState {
  @override
  List<Object?> get props => [];
}

class OrderStatusAnimationState extends OrderStatusState {
  final Animation<double> animation;
  Animation<Offset> slideAnimation;
  Animation<double>? dataAppearenceAnimation;
  @override
  List<Object?> get props =>
      [animation, slideAnimation, dataAppearenceAnimation];
  OrderStatusAnimationState(
      {required this.animation,
      required this.slideAnimation,
      required this.dataAppearenceAnimation});
}

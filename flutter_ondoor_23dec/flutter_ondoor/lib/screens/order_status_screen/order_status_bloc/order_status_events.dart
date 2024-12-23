import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

class OrderStatusEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderStatusInitialEvent extends OrderStatusEvent {
  @override
  List<Object?> get props => [];
}

class OrderStatusNullEvent extends OrderStatusEvent {
  @override
  List<Object?> get props => [];
}

class OrderStatusAnimationEvent extends OrderStatusEvent {
  final Animation<double> animation;
  Animation<Offset> slideAnimation;
  Animation<double>? dataAppearenceAnimation;
  @override
  List<Object?> get props =>
      [animation, slideAnimation, dataAppearenceAnimation];
  OrderStatusAnimationEvent(
      {required this.animation,
      required this.slideAnimation,
      required this.dataAppearenceAnimation});
}

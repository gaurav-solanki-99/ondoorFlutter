import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashScreenEvent extends Equatable {
  const SplashScreenEvent();

  @override
  List<Object?> get props => [];
}

class SplashStartEvent extends SplashScreenEvent {
  final Animation<double> animation;
  final Animation<double> imageAnimation;

  const SplashStartEvent(
      {required this.animation, required this.imageAnimation});

  @override
  List<Object?> get props => [animation, imageAnimation];
}

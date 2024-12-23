import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashScreenState extends Equatable {
  const SplashScreenState();

  @override
  List<Object?> get props => [];
}

class SplashInitialState extends SplashScreenState {
  const SplashInitialState();

  @override
  List<Object?> get props => [];
}

class SplashLoadingState extends SplashScreenState {}

class SplashStartState extends SplashScreenState {
  final Animation<double> animation;
  final Animation<double> imageAnimation;

  const SplashStartState(
      {required this.animation, required this.imageAnimation});

  @override
  List<Object?> get props => [animation, imageAnimation];
}

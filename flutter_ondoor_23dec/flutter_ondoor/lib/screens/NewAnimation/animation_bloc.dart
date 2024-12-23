import 'package:bloc/bloc.dart';

import 'animation_event.dart';
import 'animation_state.dart';


class AnimationBloc extends Bloc<AnimationEvent, AnimationState> {
  AnimationBloc() : super(AnimationInitial()) {
    on<AnimationEvent>((event, emit) {});
    on<AnimationOfferEvent>((event, emit) {emit(AnimationOfferState(size: event.size));});
    on<AnimationCartEvent>((event, emit) {emit(AnimationCartState(size: event.size));});
    on<AnimationcategoryImageEvent>((event, emit) {emit(AnimationcategoryImageState(size: event.size));});
    on<AnimatedNullEvent>((event, emit) {emit(AnimatedNullState());});
    on<offerImageEvent>((event, emit) {emit(OfferImageState(height: event.height, width: event.width));});


  }
}

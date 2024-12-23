
abstract class AnimationState {}

class AnimationInitial extends AnimationState {}

class AnimationOfferState extends AnimationState {
  double size;
  AnimationOfferState({required this.size});

}

class AnimationCartState extends AnimationState {
  double size;
  AnimationCartState({required this.size});

}

class AnimatedNullState extends AnimationState{}



class OfferImageState extends AnimationState{

  var height;
  var width;
  OfferImageState({required this.height, required this.width});
}


class AnimationcategoryImageState extends AnimationState{
  double size;
  AnimationcategoryImageState({required this.size});
}
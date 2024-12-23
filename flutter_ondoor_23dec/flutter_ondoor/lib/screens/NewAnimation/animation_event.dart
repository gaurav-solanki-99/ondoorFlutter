
abstract class AnimationEvent {}

class AnimationOfferEvent extends AnimationEvent {
  double size;
  AnimationOfferEvent({required this.size});

}


class AnimationCartEvent extends AnimationEvent {
  double size;
  AnimationCartEvent({required this.size});

}


class AnimatedNullEvent extends AnimationEvent{

}


class offerImageEvent extends AnimationEvent{

  var height;
  var width;
  offerImageEvent({required this.height, required this.width});
}



class AnimationcategoryImageEvent extends AnimationEvent{
  double size;
  AnimationcategoryImageEvent({required this.size});
}
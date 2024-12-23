abstract class VerifyEvent {}

class UpdateTimeEvent extends VerifyEvent {
  int countDownTime=0;
  UpdateTimeEvent({required this.countDownTime});

}

class ClearOTPFilledEvent extends VerifyEvent{

  String otp;
  ClearOTPFilledEvent({required this.otp});

}
class ClearFlaseOTPFilledEvent extends VerifyEvent{}
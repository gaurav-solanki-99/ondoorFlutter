
abstract class VerifyState {}

final class VerifyInitial extends VerifyState {}


class UpdateTimeState extends VerifyState {
  int countDownTime=0;
  UpdateTimeState({required this.countDownTime});

}
class ClearOTPFilledState extends VerifyState{
  String otp;
  ClearOTPFilledState({required this.otp});
}
class ClearFlaseOTPFilledState extends VerifyState{}
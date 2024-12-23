

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/AuthScreen/Verify/VerifyBloc/verify_event.dart';
import 'package:ondoor/screens/AuthScreen/Verify/VerifyBloc/verify_state.dart';

class VerifyBloc extends Bloc<VerifyEvent, VerifyState> {
  VerifyBloc() : super(VerifyInitial()) {
    on<VerifyEvent>((event, emit) {

    });




    on<UpdateTimeEvent>((event,emit){ emit(UpdateTimeState(countDownTime: event.countDownTime));});


    on<ClearOTPFilledEvent>((event, emit) {
        emit(ClearOTPFilledState(otp: event.otp));
    });


  }





}

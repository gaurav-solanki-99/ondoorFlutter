abstract class RegisterdEvent {}

class FormStateEvent extends RegisterdEvent {
  bool isvalid;
  FormStateEvent({required this.isvalid});
}

class RegisterNullEvent extends RegisterdEvent {
  RegisterNullEvent();
}



class RegisterFormFillEvent extends RegisterdEvent {
  String name;
  String mobile;
  String email;
  RegisterFormFillEvent({
    required this.name,
    required this.mobile,
    required this.email,

  });
}

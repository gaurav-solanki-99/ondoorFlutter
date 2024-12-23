abstract class RegisterdState {}

class RegisterdInitial extends RegisterdState {}

class FormStateState extends RegisterdState {
  bool isvalid;
  FormStateState({required this.isvalid});
}

class RegisterNullState extends RegisterdState {
  RegisterNullState();
}



class RegisterFormFillState extends RegisterdState {
  String name;
  String mobile;
  String email;
  RegisterFormFillState({
    required this.name,
    required this.mobile,
    required this.email,

  });
}
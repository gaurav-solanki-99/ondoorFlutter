

abstract class TopSellingState {}

class TopSellingInitial extends TopSellingState{}
class AddButtonState extends TopSellingInitial{
  int index;
  AddButtonState({required this.index});
}

class UpdateQuantityState extends TopSellingState
{
  int quanitity;
  int index;
  UpdateQuantityState({required this.quanitity,required this.index});
}



abstract class TopSellingEvent {}
class AddButtonEvent extends TopSellingEvent{
  int index;
  AddButtonEvent({required this.index});
}
class UpdateQuantityEvent extends TopSellingEvent
{
  int quanitity;
  int index;
  UpdateQuantityEvent({required this.quanitity,required this.index});
}

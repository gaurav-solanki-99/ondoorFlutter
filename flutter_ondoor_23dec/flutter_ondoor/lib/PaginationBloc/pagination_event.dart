
import '../models/AllProducts.dart';

abstract class PaginationEvent {}

class SeeAllForPaginationEvent extends PaginationEvent
{
  List<ProductData>? list;
  bool isAdded;
  SeeAllForPaginationEvent({required this.list,required this.isAdded});
}


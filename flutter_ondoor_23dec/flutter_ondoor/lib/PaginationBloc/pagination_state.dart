
import '../models/AllProducts.dart';

abstract class PaginationState {}

 class PaginationInitial extends PaginationState {}

class SeeAllForPaginationState extends PaginationState
{
  List<ProductData>? list;
  bool isAdded;
  SeeAllForPaginationState({required this.list,required this.isAdded});
}


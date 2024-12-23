import 'package:bloc/bloc.dart';
import 'package:ondoor/PaginationBloc/pagination_event.dart';
import 'package:ondoor/PaginationBloc/pagination_state.dart';




class PaginationBloc extends Bloc<PaginationEvent, PaginationState> {
  PaginationBloc() : super(PaginationInitial()) {
    on<PaginationEvent>((event, emit) {
    });

    on<SeeAllForPaginationEvent>((event,emit){
      emit(SeeAllForPaginationState(list: event.list, isAdded: event.isAdded));
    });



  }
}

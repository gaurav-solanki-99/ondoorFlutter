import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_event.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_state.dart';



class TopSellingBloc extends Bloc<TopSellingEvent, TopSellingState> {


  TopSellingBloc() : super(TopSellingInitial()) {
     on<TopSellingEvent>((event, emit) {
    });

     on<AddButtonEvent>((event,emit){

      emit(AddButtonState(index: event.index));
    });

     on<UpdateQuantityEvent>((event,emit){

      emit(UpdateQuantityState(quanitity: event.quanitity, index: event.index));
    });

  }


}

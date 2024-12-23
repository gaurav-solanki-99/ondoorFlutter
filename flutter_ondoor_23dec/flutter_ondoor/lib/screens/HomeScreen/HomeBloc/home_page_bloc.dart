import 'dart:convert';

import 'package:bloc/bloc.dart';

import '../../../constants/Constant.dart';
import '../../../constants/StringConstats.dart';
import '../../../services/ApiServices.dart';
import '../../../utils/Connection.dart';
import '../../../utils/sharedpref.dart';
import 'home_page_event.dart';
import 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageInitial()) {
    on<HomePageIntialEvent>((event, emit) {
      emit(HomePageData(
          addressline1: event.addressline1, addressline2: event.addressline2));
    });

    on<BannerScrolleEvent>((event, emit) {
      emit(BannerScrolleState(index: event.index));
    });

    on<HomePageCategoryEvent>((event, emit) {
      emit(HomePageCategoryState(
          categories: event.categories, bannersList: event.bannersList));
    });

    on<HomePageScrollEvent>((event, emit) {
      emit(HomePageScrollState(isScroll: event.isScroll));
    });

    on<HomeNotificationEvent>((event, emit) {
      emit(HomeNotificationState(notification_count: event.notification_count));
    });



    on<UpdateSearchTextHomeEvent>((event, emit) {
      emit(UpdateSearchTextHomeState(text: event.text));
    });

    on<HomeBottomSheetEvent>((event, emit) {
      emit(HomeBottomSheetState(status: event.status));
    });

    on<HomeNullEvent>((event, emit) {
      emit(HomeNullState());
    });



    on<HomePageAppBarEvent>((event,emit){
      emit(HomePageAppBarState(appbarcolor: event.appbarcolor, appbartextcolor: event.appbartextcolor));
    });
  }
}

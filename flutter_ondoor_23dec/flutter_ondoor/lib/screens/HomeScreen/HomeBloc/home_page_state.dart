
import 'package:ondoor/models/HomepageModel.dart';

abstract class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageData extends HomePageState {
  String addressline1 = "";
  String addressline2 = "";
  HomePageData({required this.addressline1, required this.addressline2});
}

class BannerScrolleState extends HomePageState {
  int index;
  BannerScrolleState({required this.index});
}

class HomePageCategoryState extends HomePageState {
  List<Category>? categories = [];
  List<Banners> bannersList = [];
  HomePageCategoryState({required this.categories, required this.bannersList});
}


class HomeNotificationState extends HomePageState{

  String notification_count;
  HomeNotificationState({required this.notification_count});
}


class HomePageScrollState extends HomePageState {
  bool isScroll;
  HomePageScrollState({required this.isScroll});
}


class UpdateSearchTextHomeState extends HomePageState{
  String text;
  UpdateSearchTextHomeState({required this.text});
}

class HomeBottomSheetState extends HomePageState{
  bool status;
  HomeBottomSheetState({required this.status});
}

class HomeNullState extends HomePageState{

}


class HomePageAppBarState extends HomePageState
{
  var appbarcolor;
  var appbartextcolor;
  HomePageAppBarState({required this.appbarcolor,required this.appbartextcolor});

}



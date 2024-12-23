import '../../../models/HomepageModel.dart';

import 'package:ondoor/models/HomepageModel.dart';

abstract class HomePageEvent {}

class HomePageIntialEvent extends HomePageEvent {
  String addressline1 = "";
  String addressline2 = "";
  HomePageIntialEvent({required this.addressline1, required this.addressline2});
}

class BannerScrolleEvent extends HomePageEvent {
  int index;
  BannerScrolleEvent({required this.index});
}

class HomePageCategoryEvent extends HomePageEvent {
  List<Category>? categories = [];
  List<Banners> bannersList = [];
  HomePageCategoryEvent({required this.categories, required this.bannersList});
}

class HomePageScrollEvent extends HomePageEvent {
  bool isScroll;
  HomePageScrollEvent({required this.isScroll});
}


class UpdateSearchTextHomeEvent extends HomePageEvent{
  String text;
  UpdateSearchTextHomeEvent({required this.text});
}


class HomeBottomSheetEvent extends HomePageEvent{
  bool status;
  HomeBottomSheetEvent({required this.status});
}

class HomeNotificationEvent extends HomePageEvent{

  String notification_count;
  HomeNotificationEvent({required this.notification_count});
}



class HomeNullEvent extends HomePageEvent{

}

class HomePageAppBarEvent extends HomePageEvent
{
  var appbarcolor;
  var appbartextcolor;
  HomePageAppBarEvent({required this.appbarcolor,required this.appbartextcolor});

}
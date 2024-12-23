import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/FontConstants.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/notification_list_response.dart';
import 'package:ondoor/screens/notification_screen/notification_bloc/notification_list_bloc.dart';
import 'package:ondoor/screens/notification_screen/notification_bloc/notification_list_event.dart';
import 'package:ondoor/screens/notification_screen/notification_bloc/notification_list_state.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';

import '../../utils/sharedpref.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  NotificationListBloc bloc = NotificationListBloc();
  List<NotificationData> notificationList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cleanData();
  }

  cleanData() async  {

    await SharedPref.setStringPreference(Constants.sp_notificationdata, "");

  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorName.whiteSmokeColor,
          appBar: Appwidgets.MyAppBar(context, "Notifications", () {}),
          /*
          appBar: AppBar(
            title: Text(
              "Notifications",
              style: Appwidgets()
                  .commonTextStyle(ColorName.ColorBagroundPrimary)
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
          ),
      */
          body: BlocBuilder(
            bloc: bloc,
            builder: (context, state) {
              print("CURRENT STATE ${state}");
              Appwidgets.setStatusBarColor();
              if (state is NotificationListInitialState) {
                isLoading = false;
                bloc.callNotificationListApi(context);
              }
              if (state is NotificationListLoadingState) {
                isLoading = true;
              }
              if (state is NotificationListLoadedState) {
                isLoading = false;
                notificationList = state.notificationList;
                 SharedPref.setIntegerPreference(Constants.show_notification_bach,notificationList.length);
              }
              if (state is NotificationViewMoreState) {
                isLoading = false;
                notificationList = state.notificationList;
                SharedPref.setIntegerPreference(Constants.show_notification_bach,notificationList.length);
              }
              return isLoading
                  ? Shimmerui.notificationListUi(context)
                  : notificationList.isEmpty
                      ? Center(
                          child: Appwidgets.Text_20(
                              "No Notification Found!!", ColorName.black),
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) => NotificationListItem(
                              notificationList[index], index),
                          itemCount: notificationList.length);
            },
          ),
        ),
      ),
    );
  }

  Widget NotificationListItem(NotificationData notificationData, int index) {
    return Card(
      margin: EdgeInsets.only(
          top: 8,
          right: 10,
          left: 10,
          bottom: notificationList.length - 1 == index ? 10 : 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: ColorName.ColorBagroundPrimary,
      child: Wrap(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  Imageconstants.ondoor_logo,
                  height: 50,
                ),
                10.toSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationData.title!,
                        style: Appwidgets()
                            .commonTextStyle(ColorName.onxy)
                            .copyWith(
                                fontFamily: Fontconstants.fc_family_sf,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                      ),
                      Text(
                        notificationData.description!,
                        maxLines: notificationData.isExpanded ? 10 : 3,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        textAlign: TextAlign.justify,
                        style: Appwidgets()
                            .commonTextStyle(ColorName.textlight2)
                            .copyWith(
                                fontFamily: Fontconstants.fc_family_sf,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                      ),
                      notificationData.description!.length <
                              Sizeconfig.getWidth(context) * .352
                          ? SizedBox.shrink()
                          : GestureDetector(
                              onTap: () {
                                notificationData.isExpanded =
                                    !notificationData.isExpanded;
                                bloc.add(NotificationViewMoreEvent(
                                    notificationList: notificationList));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    notificationData.isExpanded
                                        ? StringContants.lbl_view_less
                                        : StringContants.lbl_view_more,
                                    style: Appwidgets()
                                        .commonTextStyle(ColorName.darkBlue)
                                        .copyWith(
                                            fontSize: Constants.SizeMidium,
                                            fontWeight:
                                                Fontconstants.Poppins_Regular),
                                  ),
                                  Icon(
                                    notificationData.isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: ColorName.darkBlue,
                                  )
                                ],
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
          notificationData.image == ""
              ? SizedBox.shrink()
              : ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)),
                  child: CachedNetworkImage(
                      errorWidget: (context, url, error) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Image.asset(
                              Imageconstants.ondoor_logo,
                              width: Sizeconfig.getWidth(context),
                              height: 100,
                            ),
                          ),
                      useOldImageOnUrlChange: true,
                      cacheKey: notificationData.image!,
                      colorBlendMode: BlendMode.clear,
                      repeat: ImageRepeat.repeat,
                      filterQuality: FilterQuality.medium,
                      // height: height,
                      // width: width,
                      fit: BoxFit.fitHeight,
                      imageUrl: notificationData.image!,
                      placeholder: (context, url) =>
                          Shimmerui.bannerUI(context)),
                )
        ],
      ),
    );
  }
}

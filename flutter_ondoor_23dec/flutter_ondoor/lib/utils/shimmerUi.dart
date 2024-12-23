import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

import 'SizeConfig.dart';

class Shimmerui {
  static int offset = 0;
  static int time = 1500;

  static var shimmerColor = Colors.grey.withOpacity(0.4);

  static bannerUI(BuildContext context) {
    return Container(
        width: Sizeconfig.getWidth(context),
        height: Sizeconfig.getHeight(context) * 0.22,
        color: shimmerColor,
        child: Shimmer.fromColors(
          highlightColor: Colors.white,
          baseColor: Colors.white38,
          child: Container(
            color: ColorName.textlight,
          ),
          period: Duration(milliseconds: time),
        ));
  }

  static locationDetailShimmerUI(
      {required BuildContext context, required double width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: Sizeconfig.getWidth(context) * 0.6,
            height: 16,
            color: shimmerColor,
            margin: EdgeInsets.zero,
            child: Shimmer.fromColors(
              highlightColor: ColorName.ColorPrimary,
              baseColor: Colors.white38,
              child: Container(
                color: ColorName.textlight,
              ),
              period: Duration(milliseconds: time),
            )),
        Container(
            width: Sizeconfig.getWidth(context) * 0.5,
            height: 15,
            color: shimmerColor,
            margin: EdgeInsets.only(top: 5),
            child: Shimmer.fromColors(
              highlightColor: ColorName.ColorPrimary,
              baseColor: Colors.white38,
              child: Container(
                color: ColorName.textlight,
              ),
              period: Duration(milliseconds: time),
            )),
      ],
    );
  }

  static shimmer_for_profile(BuildContext context, double width) {
    return Wrap(
      direction: Axis.vertical,
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        20.toSpace,
        Container(
            width: width + 80,
            height: 16,
            color: shimmerColor,
            margin: EdgeInsets.zero,
            child: Shimmer.fromColors(
              highlightColor: ColorName.ColorBagroundPrimary,
              baseColor: Colors.white38,
              child: Container(
                color: ColorName.textlight,
              ),
              period: Duration(milliseconds: time),
            )),
        Container(
            width: width,
            height: 16,
            color: shimmerColor,
            margin: EdgeInsets.only(top: 10),
            child: Shimmer.fromColors(
              highlightColor: ColorName.ColorBagroundPrimary,
              baseColor: Colors.white38,
              child: Container(
                color: ColorName.textlight,
              ),
              period: Duration(milliseconds: time),
            )),
      ],
    );
  }

  static shimmer_for_street_and_city_location(
      BuildContext context, double width) {
    return Wrap(
      direction: Axis.vertical,
      children: [
        5.toSpace,
        Container(
            width: width + 80,
            height: 15,
            decoration: BoxDecoration(
                color: shimmerColor, borderRadius: BorderRadius.circular(5)),
            margin: EdgeInsets.zero,
            child: Shimmer.fromColors(
              highlightColor: ColorName.ColorBagroundPrimary,
              baseColor: Colors.white38,
              child: Container(
                color: ColorName.textlight,
              ),
              period: Duration(milliseconds: time),
            )),
        Container(
            width: width,
            height: 15,
            decoration: BoxDecoration(
                color: shimmerColor, borderRadius: BorderRadius.circular(5)),
            margin: EdgeInsets.only(top: 10),
            child: Shimmer.fromColors(
              highlightColor: ColorName.ColorBagroundPrimary,
              baseColor: Colors.white38,
              child: Container(
                color: ColorName.textlight,
              ),
              period: Duration(milliseconds: time),
            )),
      ],
    );
  }

  static shimmer_for_profileLogo(BuildContext context, double width) {
    return Container(
        width: width + 80,
        height: width + 80,
        decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(width + 50)),
        margin: EdgeInsets.zero,
        child: Shimmer.fromColors(
          highlightColor: ColorName.ColorBagroundPrimary,
          baseColor: Colors.white38,
          child: Container(
            color: ColorName.textlight,
          ),
          period: Duration(milliseconds: time),
        ));
  }

  static shimmer_for_locationMarker(BuildContext context, double size) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: shimmerColor, borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        child: Shimmer.fromColors(
          highlightColor: ColorName.ColorBagroundPrimary,
          baseColor: Colors.white38,
          child: Container(
            color: ColorName.textlight,
          ),
          period: Duration(milliseconds: time),
        ));
  }

  static locationloadingWidget(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        height: Sizeconfig.getHeight(context) * .18,
        decoration: BoxDecoration(
          // color: shimmerColor,
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.black26,
              period: Duration(milliseconds: time),
              child: Container(
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
            Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.black26,
              period: Duration(milliseconds: time),
              child: Container(
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
            Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.black26,
              period: Duration(milliseconds: time),
              child: Container(
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ],
        ));
  }

  static productListUi(BuildContext context) {
    // return Container(
    //     height: Sizeconfig.getHeight(context),
    //     padding: EdgeInsets.only(top: 10),
    //     child: ListView.builder(
    //       shrinkWrap: true,
    //       itemCount: 10,
    //       itemBuilder: (context, index) {
    //         return Container(
    //             height: Sizeconfig.getHeight(context) * 0.16,
    //             margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
    //             decoration: BoxDecoration(
    //               color: shimmerColor,
    //               borderRadius: BorderRadius.circular(10),
    //             ),
    //             child: Shimmer.fromColors(
    //               highlightColor: Colors.white,
    //               baseColor: Colors.white38,
    //               child: Container(
    //                 color: ColorName.textlight,
    //               ),
    //               period: Duration(milliseconds: time),
    //             ));
    //       },
    //     ));
    return Container(
        height: Sizeconfig.getHeight(context),
        color: ColorName.whiteSmokeColor,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              height: 95,
              decoration: BoxDecoration(
                color: ColorName.ColorBagroundPrimary,
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                        height: 80,
                        width: Sizeconfig.getWidth(context) / 2,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.white38,
                          child: Container(
                            color: ColorName.textlight,
                          ),
                          period: Duration(milliseconds: time),
                        )),
                  ),
                  5.toSpace,
                  Expanded(
                      flex: 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                    width: Sizeconfig.getWidth(context) * .32,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Shimmer.fromColors(
                                      highlightColor: Colors.white,
                                      baseColor: Colors.white38,
                                      child: Container(
                                        color: ColorName.textlight,
                                      ),
                                      period: Duration(milliseconds: time),
                                    )),
                                Spacer(),
                                Container(
                                    width: Sizeconfig.getWidth(context) * .2,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Shimmer.fromColors(
                                      highlightColor: Colors.white,
                                      baseColor: Colors.white38,
                                      child: Container(
                                        color: ColorName.textlight,
                                      ),
                                      period: Duration(milliseconds: time),
                                    )),
                              ],
                            ),
                          ),
                          5.toSpace,
                          Container(
                              height: 10,
                              width: Sizeconfig.getWidth(context) * .28,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 10,
                              width: Sizeconfig.getWidth(context) * .23,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 10,
                                      width: Sizeconfig.getWidth(context) * .18,
                                      decoration: BoxDecoration(
                                        color: shimmerColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Shimmer.fromColors(
                                        highlightColor: Colors.white,
                                        baseColor: Colors.white38,
                                        child: Container(
                                          color: ColorName.textlight,
                                        ),
                                        period: Duration(milliseconds: time),
                                      )),
                                  5.toSpace,
                                  Container(
                                      height: 10,
                                      width: Sizeconfig.getWidth(context) * .13,
                                      decoration: BoxDecoration(
                                        color: shimmerColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Shimmer.fromColors(
                                        highlightColor: Colors.white,
                                        baseColor: Colors.white38,
                                        child: Container(
                                          color: ColorName.textlight,
                                        ),
                                        period: Duration(milliseconds: time),
                                      )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                  height: 20,
                                  width: Sizeconfig.getWidth(context) * .23,
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    child: Container(
                                      color: ColorName.textlight,
                                    ),
                                    period: Duration(milliseconds: time),
                                  )),
                            ],
                          )
                        ],
                      )),
                  5.toSpace,
                ],
              ),
            );
          },
        ));
  }

  static cartproductListUi(BuildContext context) {
    return Container(
        height: Sizeconfig.getHeight(context),
        color: ColorName.whiteSmokeColor,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              height: 95,
              decoration: BoxDecoration(
                color: ColorName.ColorBagroundPrimary,
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.only(top: 1),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                        height: 80,
                        width: Sizeconfig.getWidth(context) / 2,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.white38,
                          child: Container(
                            color: ColorName.textlight,
                          ),
                          period: Duration(milliseconds: time),
                        )),
                  ),
                  5.toSpace,
                  Expanded(
                      flex: 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                    width: Sizeconfig.getWidth(context) * .32,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Shimmer.fromColors(
                                      highlightColor: Colors.white,
                                      baseColor: Colors.white38,
                                      child: Container(
                                        color: ColorName.textlight,
                                      ),
                                      period: Duration(milliseconds: time),
                                    )),
                                Spacer(),
                                Container(
                                    width: Sizeconfig.getWidth(context) * .2,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Shimmer.fromColors(
                                      highlightColor: Colors.white,
                                      baseColor: Colors.white38,
                                      child: Container(
                                        color: ColorName.textlight,
                                      ),
                                      period: Duration(milliseconds: time),
                                    )),
                              ],
                            ),
                          ),
                          5.toSpace,
                          Container(
                              height: 10,
                              width: Sizeconfig.getWidth(context) * .28,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 10,
                              width: Sizeconfig.getWidth(context) * .23,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 10,
                                      width: Sizeconfig.getWidth(context) * .18,
                                      decoration: BoxDecoration(
                                        color: shimmerColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Shimmer.fromColors(
                                        highlightColor: Colors.white,
                                        baseColor: Colors.white38,
                                        child: Container(
                                          color: ColorName.textlight,
                                        ),
                                        period: Duration(milliseconds: time),
                                      )),
                                  5.toSpace,
                                  Container(
                                      height: 10,
                                      width: Sizeconfig.getWidth(context) * .13,
                                      decoration: BoxDecoration(
                                        color: shimmerColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Shimmer.fromColors(
                                        highlightColor: Colors.white,
                                        baseColor: Colors.white38,
                                        child: Container(
                                          color: ColorName.textlight,
                                        ),
                                        period: Duration(milliseconds: time),
                                      )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                  height: 20,
                                  width: Sizeconfig.getWidth(context) * .23,
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    child: Container(
                                      color: ColorName.textlight,
                                    ),
                                    period: Duration(milliseconds: time),
                                  )),
                            ],
                          )
                        ],
                      )),
                  5.toSpace,
                ],
              ),
            );
          },
        ));
  }

  static orderHistoryListUi(BuildContext context) {
    return Container(
        height: Sizeconfig.getHeight(context),
        color: ColorName.whiteSmokeColor,
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: ColorName.ColorBagroundPrimary,
              margin: EdgeInsets.only(right: 10, top: 10, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Shimmer.fromColors(
                              highlightColor: Colors.white,
                              baseColor: Colors.white38,
                              child: Container(
                                color: ColorName.textlight,
                              ),
                              period: Duration(milliseconds: time),
                            )),
                        10.toSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 10,
                                  width: Sizeconfig.getWidth(context),
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    child: Container(
                                      color: ColorName.textlight,
                                    ),
                                    period: Duration(milliseconds: time),
                                  )),
                              5.toSpace,
                              Container(
                                  height: 10,
                                  width: Sizeconfig.getWidth(context),
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    child: Container(
                                      color: ColorName.textlight,
                                    ),
                                    period: Duration(milliseconds: time),
                                  )),
                            ],
                          ),
                        ),
                        10.toSpace,
                        Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Shimmer.fromColors(
                              highlightColor: Colors.white,
                              baseColor: Colors.white38,
                              child: Container(
                                color: ColorName.textlight,
                              ),
                              period: Duration(milliseconds: time),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.white38,
                          child: Container(
                            color: ColorName.textlight,
                          ),
                          period: Duration(milliseconds: time),
                        )),
                  ),
                  Container(
                      height: 30,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Shimmer.fromColors(
                        highlightColor: Colors.white,
                        baseColor: Colors.white38,
                        child: Container(
                          color: ColorName.textlight,
                        ),
                        period: Duration(milliseconds: time),
                      )),
                  10.toSpace,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                        ),
                        16.toSpace,
                        Expanded(
                          child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  static notificationListUi(BuildContext context) {
    return Container(
        height: Sizeconfig.getHeight(context),
        color: ColorName.whiteSmokeColor,
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              color: ColorName.ColorBagroundPrimary,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  5.toSpace,
                  Expanded(
                    flex: 4,
                    child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.white38,
                          child: Container(
                            color: ColorName.textlight,
                          ),
                          period: Duration(milliseconds: time),
                        )),
                  ),
                  10.toSpace,
                  Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 10,
                              width: Sizeconfig.getWidth(context) / 4,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                        ],
                      )),
                  5.toSpace,
                ],
              ),
            );
          },
        ));
  }

  static filterListUi(BuildContext context) {
    // return ListView.builder(
    //   itemCount: 3,
    //   shrinkWrap: true,
    //   scrollDirection: Axis.horizontal,
    //   itemBuilder: (context, index) => Container(
    //       height: 50,
    //       width: 100,
    //       margin: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    //       decoration: BoxDecoration(
    //         color: shimmerColor,
    //         borderRadius: BorderRadius.circular(5),
    //       ),
    //       child: Shimmer.fromColors(
    //         highlightColor: Colors.white,
    //         baseColor: Colors.white38,
    //         child: Container(
    //           color: ColorName.textlight,
    //         ),
    //         period: Duration(milliseconds: time),
    //       )),
    // );
    return Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Shimmer.fromColors(
          highlightColor: Colors.white,
          baseColor: Colors.white38,
          child: Container(
            color: ColorName.textlight,
          ),
          period: Duration(milliseconds: time),
        ));
  }

  static shimmerForSingleTextWidget(BuildContext context) {
    return Container(
        height: 15,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Shimmer.fromColors(
          highlightColor: Colors.white,
          baseColor: Colors.white38,
          child: Container(
            color: ColorName.textlight,
          ),
          period: Duration(milliseconds: time),
        ));
  }

  static shopByCategoryproductListUi(BuildContext context) {
    return Container(
        height: Sizeconfig.getHeight(context),
        color: ColorName.whiteSmokeColor,
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: ColorName.ColorBagroundPrimary,
              ),
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                        height: Sizeconfig.getHeight(context) * .11,
                        width: Sizeconfig.getWidth(context) * .5,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.white38,
                          child: Container(
                            color: ColorName.textlight,
                          ),
                          period: Duration(milliseconds: time),
                        )),
                  ),
                  5.toSpace,
                  Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          5.toSpace,
                          Container(
                              height: 10,
                              width: Sizeconfig.getWidth(context),
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Container(
                              height: 20,
                              width: Sizeconfig.getWidth(context) / 5,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                child: Container(
                                  color: ColorName.textlight,
                                ),
                                period: Duration(milliseconds: time),
                              )),
                          5.toSpace,
                          Row(
                            children: [
                              Container(
                                  height: 20,
                                  width: Sizeconfig.getWidth(context) / 7,
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    child: Container(
                                      color: ColorName.textlight,
                                    ),
                                    period: Duration(milliseconds: time),
                                  )),
                              Spacer(),
                              Container(
                                  height: 20,
                                  width: Sizeconfig.getWidth(context) / 8,
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    child: Container(
                                      color: ColorName.textlight,
                                    ),
                                    period: Duration(milliseconds: time),
                                  )),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            );
          },
        ));
  }

  static shimmerForProductImageWidget({
    required BuildContext context,
    required double height,
    required double width,
  }) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Shimmer.fromColors(
          highlightColor: Colors.white,
          baseColor: Colors.white38,
          child: Container(
            color: ColorName.textlight,
          ),
          period: Duration(milliseconds: time),
        ));
  }

  static addressListUi(BuildContext context, double height) {
    return Container(
        height: Sizeconfig.getHeight(context),
        color: ColorName.whiteSmokeColor,
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              height: height,
              width: Sizeconfig.getWidth(context),
              margin: EdgeInsets.all(8),
              color: ColorName.ColorBagroundPrimary,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Shimmer.fromColors(
                        highlightColor: Colors.white,
                        baseColor: Colors.white38,
                        period: Duration(milliseconds: time),
                        child: Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: ColorName.textlight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 15,
                                  width: Sizeconfig.getWidth(context) / 2.7,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    period: Duration(milliseconds: time),
                                    child: Container(
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: ColorName.textlight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )),
                              Container(
                                  height: 30,
                                  width: 80,
                                  margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                                  decoration: BoxDecoration(
                                    color: shimmerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.white38,
                                    period: Duration(milliseconds: time),
                                    child: Container(
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: ColorName.textlight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                          Container(
                              height: 20,
                              width: Sizeconfig.getWidth(context) / 4,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5),
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Shimmer.fromColors(
                                highlightColor: Colors.white,
                                baseColor: Colors.white38,
                                period: Duration(milliseconds: time),
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: ColorName.textlight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ))
                        ],
                      ))
                ],
              ),
            );
          },
        ));
  }

  static GridViewUi(BuildContext context) {
    var item = ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
          width: Sizeconfig.getWidth(context) / 4.6,
          height: Sizeconfig.getHeight(context) * 0.11,
          color: shimmerColor,
          child: Shimmer.fromColors(
            highlightColor: Colors.white,
            baseColor: Colors.white38,
            child: Container(
              color: ColorName.textlight,
            ),
            period: Duration(milliseconds: time),
          )),
    );
    return Container(
      height: Sizeconfig.getHeight(context) * 0.25,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              item,
              item,
              item,
              item,
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              item,
              item,
              item,
              item,
            ],
          ),
        ],
      ),
    );
  }

  static orderSummaryui(BuildContext context) {
    return Container(
        height: Sizeconfig.getHeight(context) * 0.8,
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              height: Sizeconfig.getHeight(context) * 0.38,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: Sizeconfig.getHeight(context) * 0.02,
                      width: Sizeconfig.getWidth(context) / 2,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Shimmer.fromColors(
                        highlightColor: Colors.white,
                        baseColor: Colors.white38,
                        child: Container(
                          color: ColorName.textlight,
                        ),
                        period: Duration(milliseconds: time),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: Sizeconfig.getHeight(context) * 0.01,
                      width: Sizeconfig.getWidth(context) * 0.4,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Shimmer.fromColors(
                        highlightColor: Colors.white,
                        baseColor: Colors.white38,
                        child: Container(
                          color: ColorName.textlight,
                        ),
                        period: Duration(milliseconds: time),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: Sizeconfig.getHeight(context) * 0.29,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: Sizeconfig.getWidth(context) * 0.36,
                              margin: EdgeInsets.only(right: 8),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: Sizeconfig.getWidth(context) *
                                              0.36,
                                          // color: Colors.grey,
                                          decoration: BoxDecoration(
                                            color: shimmerColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Shimmer.fromColors(
                                            highlightColor: Colors.white,
                                            baseColor: Colors.white38,
                                            child: Container(
                                              color: ColorName.textlight,
                                            ),
                                            period:
                                                Duration(milliseconds: time),
                                          )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                          height:
                                              Sizeconfig.getHeight(context) *
                                                  0.01,
                                          width: Sizeconfig.getWidth(context) *
                                              0.32,
                                          decoration: BoxDecoration(
                                            color: shimmerColor,
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          child: Shimmer.fromColors(
                                            highlightColor: Colors.white,
                                            baseColor: Colors.white38,
                                            child: Container(
                                              color: ColorName.textlight,
                                            ),
                                            period:
                                                Duration(milliseconds: time),
                                          )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                          height:
                                              Sizeconfig.getHeight(context) *
                                                  0.01,
                                          width: Sizeconfig.getWidth(context) *
                                              0.25,
                                          decoration: BoxDecoration(
                                            color: shimmerColor,
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          child: Shimmer.fromColors(
                                            highlightColor: Colors.white,
                                            baseColor: Colors.white38,
                                            child: Container(
                                              color: ColorName.textlight,
                                            ),
                                            period:
                                                Duration(milliseconds: time),
                                          )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),
                                      Container(
                                          height:
                                              Sizeconfig.getHeight(context) *
                                                  0.03,
                                          width: Sizeconfig.getWidth(context) *
                                              0.15,
                                          decoration: BoxDecoration(
                                            color: shimmerColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Shimmer.fromColors(
                                            highlightColor: Colors.white,
                                            baseColor: Colors.white38,
                                            child: Container(
                                              color: ColorName.textlight,
                                            ),
                                            period:
                                                Duration(milliseconds: time),
                                          )),
                                    ],
                                  ),
                                ],
                              ),

                              // decoration: BoxDecoration(
                              // color: shimmerColor,
                              // borderRadius: BorderRadius.circular(0),
                              // ),
                              // child: Shimmer.fromColors(
                              // highlightColor: Colors.white,
                              // baseColor: Colors.white38,
                              // child: Container(
                              // color: ColorName.textlight,
                              // ),
                              // period: Duration(milliseconds: time),
                              // )
                            );
                          }))
                ],
              ),
            );
          },
        ));
  }
}

class ShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 150;
    double containerHeight = 15;

    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 9 / 11,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(1),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          SizedBox(height: 2),
        ],
      ),
    );
  }
}

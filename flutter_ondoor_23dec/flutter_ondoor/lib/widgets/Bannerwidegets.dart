import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';

import '../../../models/HomepageModel.dart';
import '../../../utils/colors.dart';
import '../constants/StringConstats.dart';
import '../models/AllProducts.dart';
import '../screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import '../screens/HomeScreen/HomeBloc/home_page_event.dart';
import '../screens/HomeScreen/HomeBloc/home_page_state.dart';
import '../services/Navigation/routes.dart';
import '../utils/Comman_Loader.dart';

class BannerView extends StatefulWidget {
  final List<Banners> bannerList;
  final Function(int)? onPageChanged;
  final bool showindicator;

  BannerView(
      {required this.bannerList,
      required this.showindicator,
      this.onPageChanged});

  @override
  _BannerViewState createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  late PageController _pageController;
  late Timer _timer;
  HomePageBloc homePageBloc = HomePageBloc();
  int _currentPosition = 0;

  @override
  void initState() {
    super.initState();

    if (widget.showindicator == false) {
      _pageController = PageController(
        initialPage: _currentPosition,
        viewportFraction: 0.9,
      );
    } else {
      _pageController = PageController(
        initialPage: _currentPosition,
      );
    }

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPosition < widget.bannerList.length - 1) {
        _currentPosition++;
      } else {
        _currentPosition = 0;
      }
      _pageController.animateToPage(
        _currentPosition,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decorator = DotsDecorator(
      spacing: EdgeInsets.all(2),
      activeColor: ColorName.lightRed,
      size: const Size.square(8.0),
      activeSize: const Size(15.0, 8.0),
      activeShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );

    return BlocBuilder<HomePageBloc, HomePageState>(
        bloc: homePageBloc,
        builder: (context, state) {
          if (state is BannerScrolleState) {
            _currentPosition = state.index;
          }
          return Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      height: Sizeconfig.getHeight(context) * 0.22,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.bannerList.length,
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padEnds: true,
                        pageSnapping: true,
                        dragStartBehavior: DragStartBehavior.start,
                        onPageChanged: (int page) {
                          _currentPosition = page;
                          homePageBloc
                              .add(BannerScrolleEvent(index: _currentPosition));
                          widget.onPageChanged?.call(page);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () async {
                              if (widget.bannerList[index].key == "4") {
                                await SharedPref.setStringPreference(
                                    Constants.sp_bannerProductTitle,
                                    widget.bannerList[index].headerTitle ?? "");
                                List<ProductData> list = [];
                                Navigator.pushNamed(
                                    context, Routes.featuredProduct,
                                    arguments: {
                                      "key": StringContants.lbl_bannersprodcut +
                                          widget.bannerList[index].value!
                                              .trim(),
                                      "list": list,
                                      "paninatinUrl": ""
                                    }).then((value) {});
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: CachedNetworkImage(
                                  imageUrl: widget.bannerList[index].image!,
                                  width: Sizeconfig.getWidth(context),
                                  height: Sizeconfig.getHeight(context) * 0.22,
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) =>
                                      Shimmerui.bannerUI(context),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    10.toSpace,
                    widget.bannerList.isNotEmpty
                        ? (widget.showindicator
                            ? DotsIndicator(
                                dotsCount: widget.bannerList.length,
                                position: _currentPosition,
                                reversed: false,
                                decorator: decorator,
                              )
                            : Container())
                        : Container(),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

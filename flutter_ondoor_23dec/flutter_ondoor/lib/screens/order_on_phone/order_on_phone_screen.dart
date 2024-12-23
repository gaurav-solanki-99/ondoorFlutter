import 'package:flutter/material.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/ApiServices.dart';

class OrderOnPhoneScreen extends StatefulWidget {
  const OrderOnPhoneScreen({super.key});

  @override
  State<OrderOnPhoneScreen> createState() => _OrderOnPhoneScreenState();
}

class _OrderOnPhoneScreenState extends State<OrderOnPhoneScreen> {
  String telephone = "9876543210";
  @override
  void initState() {
    // TODO: implement initState
    Appwidgets.setStatusBarColor();
    getOrderonPhone();
    super.initState();
  }

  void getOrderonPhone() async {
    if (await Network.isConnected()) {
      // EasyLoading.show();
      ApiProvider().getOrderonPhone().then((value) async {
        setState(() {
          // EasyLoading.dismiss();
          telephone = value.data!.telephone!;
        });
      });
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getOrderonPhone();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalpadding = Sizeconfig.getWidth(context);
    double verticalpadding = Sizeconfig.getHeight(context);
    return SafeArea(
      child: Scaffold(
        appBar: Appwidgets.MyAppBar(context, "Order By Phone", () {}),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  Imageconstants.order_by_phone_frame,
                  fit: BoxFit.fill,
                  height: Sizeconfig.getHeight(context),
                  // width: Sizeconfig.getWidth(context) * .75,
                ),
              ),
              SizedBox(
                // color: ColorName.ColorPrimary,
                width: Sizeconfig.getWidth(context) * .85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Imageconstants.ondoor_logo,
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(
                      height: Sizeconfig.getHeight(context) * .15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        StringContants.lbl_call_us_now_place_your_order,
                        textAlign: TextAlign.center,
                        style: Appwidgets()
                            .commonTextStyle(ColorName.black)
                            .copyWith(
                                fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      // child: Appwidgets.Text_18(
                      //     "Call us now and place your grocery order with ease!",
                      //     ColorName.black),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: telephone == ""
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: () => _dialNumber(telephone),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.symmetric(
                      horizontal: horizontalpadding * .14,
                      vertical: verticalpadding * .051),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      5.toSpace,
                      Text(
                        "Call Now",
                        // telephone,
                        style: Appwidgets()
                            .commonTextStyle(ColorName.ColorBagroundPrimary)
                            .copyWith(
                                fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
/*
        body: SizedBox(
          width: double.infinity,
          child: Center(
            child: GestureDetector(
              onTap: () {
                _dialNumber(telephone);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    direction: Axis.vertical,
                    runAlignment: WrapAlignment.center,
                    runSpacing: 10,
                    children: [
                      Text(
                        "ORDER ON PHONE",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.black)
                            .copyWith(
                                fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      10.toSpace,

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
*/
      ),
    );
  }

  void _dialNumber(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
    } catch (exception) {
      debugPrint("EXCEPTION  $exception");
    }
  }
}

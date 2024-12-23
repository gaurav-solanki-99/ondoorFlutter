import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:ondoor/models/get_page_response.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/FontConstants.dart';

class CompanyInfoPage extends StatefulWidget {
  String page_id = "";
  String page_name = "";
  CompanyInfoPage({
    super.key,
    required this.page_id,
    required this.page_name,
  });

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  String appBarText = "";
  String bodyText = "";
  WebViewController webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    Appwidgets.setStatusBarColor();
    getPagesData();
    super.initState();
  }

  getPagesData() async {
    webViewController = WebViewController();
    if (await Network.isConnected()) {
      GetPagesResponse getPagesResponse =
          await ApiProvider().getpages(widget.page_id);
      setState(() {
        appBarText = getPagesResponse.data!.title!;
        bodyText = getPagesResponse.data!.description!;
        // webViewController.loadHtmlString(bodyText);
        // webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
        // webViewController.clearCache();
        // webViewController.enableZoom(true);
        //
        // webViewController.setBackgroundColor(ColorName.ColorBagroundPrimary);
      });
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getPagesData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.page_name,
              style: TextStyle(color: ColorName.ColorBagroundPrimary),
            ),
            // title: HtmlWidget(
            //   appBarText,
            //   textStyle: TextStyle(color: ColorName.ColorBagroundPrimary),
            // ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
          ),
          body: appBarText == "" && bodyText == ""
              ? companyInfoLoader(context)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: SingleChildScrollView(
                      child: HtmlWidget(
                    bodyText,
                    enableCaching: true,
                    buildAsync: true,
                    onLoadingBuilder: (context, element, loadingProgress) {
                      return companyInfoLoader(context);
                    },
                    onTapUrl: (p0) async {
                      print("TAPPEDJJFHHFHH ${p0}");
                      try {
                        await launchUrl(Uri.parse(p0));
                      } catch (e) {
                        print("Error While Loading url $e");
                      }
                      return true;
                    },
                    textStyle: TextStyle(color: ColorName.black),
                  )),
                )
          /* : Padding(
                padding: const EdgeInsets.all(10),
                child: WebViewWidget(
                  controller: webViewController,
                ),
              ),*/
          ),
    );
  }

  Widget companyInfoLoader(context) {
    return SizedBox(
        height: Sizeconfig.getHeight(context) * .85,
        width: Sizeconfig.getWidth(context),
        child: const Center(child: CommonLoadingWidget()));
  }
}

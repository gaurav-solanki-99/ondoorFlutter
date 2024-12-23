import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/utils/colors.dart';

class CommanLoader {
  configEasyLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.light
      ..indicatorSize = 50.0
      ..radius = 10.0
      ..backgroundColor = ColorName.transprent
      ..progressColor = ColorName.ColorPrimary
      ..backgroundColor = ColorName.ColorBagroundPrimary
      ..indicatorColor = ColorName.aquaHazeColor
      ..textColor = ColorName.textlight
      ..maskColor = ColorName.darkGrey
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  dismissEasyLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';

class OndoorLoaderWidget extends StatefulWidget {
  OndoorLoaderWidget({super.key});

  @override
  State<OndoorLoaderWidget> createState() => _OndoorLoaderWidgetState();
}

class _OndoorLoaderWidgetState extends State<OndoorLoaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Stack(alignment: Alignment.center, children: [
              Image.asset(
                Imageconstants.ondoor_logo_for_loading,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset(Imageconstants.ondoor_logo_for_loading),
                height: 40,
                width: 40,
              ),
              const CircularProgressIndicator(
                  color: ColorName.ColorPrimary,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 3,
                  strokeAlign: 2.5)
            ]),
            10.toSpace,
            Text(
              "Loading...",
              style: Appwidgets()
                  .commonTextStyle(ColorName.ColorPrimary.withOpacity(.8))
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}

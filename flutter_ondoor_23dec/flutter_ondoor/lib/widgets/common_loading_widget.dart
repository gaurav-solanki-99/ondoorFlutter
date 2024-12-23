import 'package:flutter/material.dart';
import 'package:ondoor/utils/colors.dart';

class CommonLoadingWidget extends StatelessWidget {
  const CommonLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorName.ColorPrimary,
      ),
    );
  }
}

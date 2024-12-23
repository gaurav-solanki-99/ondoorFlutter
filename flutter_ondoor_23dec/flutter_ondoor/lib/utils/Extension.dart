import 'package:flutter/widgets.dart';

extension Space on int {
  Widget get toSpace {
    return SizedBox(
      height: toDouble(),
      width: toDouble(),
    );
  }
}

extension StringExtension on String {
  String capitalizeByWord() {
    if (trim().isEmpty) {
      return '';
    }
    return split(' ')
        .map((element) =>
            "${element[0].toUpperCase()}${element.substring(1).toLowerCase()}")
        .join(" ");
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

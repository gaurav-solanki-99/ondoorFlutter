import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoor/constants/ImageConstants.dart';

class CommonCachedImageWidget extends StatelessWidget {
  String imgUrl;
  final double? height;
  final double? width;
  CommonCachedImageWidget(
      {super.key, required this.imgUrl, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        errorWidget: (context, url, error) =>
            Image.asset(Imageconstants.ondoor_logo,fit: BoxFit.fill,),
        useOldImageOnUrlChange: true,
        cacheKey: imgUrl,
        colorBlendMode: BlendMode.clear,
        repeat: ImageRepeat.repeat,
        filterQuality: FilterQuality.medium,
        height: height,
        width: width,
        fit: BoxFit.fill,
        imageUrl: imgUrl,
        placeholder: (context, url) => const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CupertinoActivityIndicator(),
            )));
  }
}

class CommonCachedImageWidget2 extends StatelessWidget {
  String imgUrl;
  final double? height;
  final double? width;
  CommonCachedImageWidget2(
      {super.key, required this.imgUrl, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        errorWidget: (context, url, error) =>
            Image.asset(Imageconstants.ondoor_logo),
        useOldImageOnUrlChange: true,
        cacheKey: imgUrl,
        colorBlendMode: BlendMode.clear,
        repeat: ImageRepeat.repeat,
        filterQuality: FilterQuality.medium,
        height: height,
        width: width,
        imageUrl: imgUrl,
        placeholder: (context, url) => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CupertinoActivityIndicator(),
            )));
  }
}
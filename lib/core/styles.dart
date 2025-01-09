import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';

class CoreStyles {
  static const TextStyle h1 = TextStyle(fontFamily: 'Mulish', fontSize: 47, color: CoreColors.primary);

  static const TextStyle h3 = TextStyle(fontFamily: 'Mulish', fontSize: 24, color: CoreColors.black);

  static const TextStyle h4 = TextStyle(fontFamily: 'Mulish', fontSize: 14, height: 1, color: CoreColors.black);

  static const TextStyle h4MultiLine = TextStyle(fontFamily: 'Mulish', fontSize: 14, color: CoreColors.black);

  static const TextStyle hint = TextStyle(fontFamily: 'Mulish', fontSize: 12, color: CoreColors.grey);

  static const TextStyle buttonTextOnPrimary =
      TextStyle(fontFamily: 'Mulish', fontWeight: FontWeight.w700, height: 1, fontSize: 16, color: CoreColors.white);

  static const TextStyle bannerTitle = TextStyle(
      fontFamily: 'Mulish',
      fontSize: 16,
      shadows: [Shadow(color: CoreColors.black, blurRadius: 10)],
      color: CoreColors.white);

  static const TextStyle bannerSubTitle = TextStyle(
      fontFamily: 'Mulish',
      fontSize: 10,
      shadows: [Shadow(color: CoreColors.black, blurRadius: 10)],
      color: CoreColors.white);

  static const TextStyle bannerButton =
      TextStyle(fontFamily: 'Mulish', fontSize: 10, height: 1, color: CoreColors.black);

  static const TextStyle categoryButton =
      TextStyle(fontFamily: 'Mulish', fontSize: 10, height: 1, color: CoreColors.white);

  static const TextStyle listTile = TextStyle(fontFamily: 'Mulish', fontSize: 16, color: CoreColors.black);

  static const TextStyle searchTitle = TextStyle(fontFamily: 'Mulish', fontSize: 14, color: CoreColors.black);

  static const TextStyle chip = TextStyle(fontFamily: 'Mulish', fontSize: 12, color: CoreColors.white);

  static const TextStyle cartPrice = TextStyle(fontFamily: 'Mulish', fontSize: 20, color: CoreColors.black);

  static const TextStyle searchLetter = TextStyle(fontFamily: 'Mulish', fontSize: 20, color: CoreColors.primary);
}

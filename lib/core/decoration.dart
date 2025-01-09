import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/styles.dart';

class CoreDecoration {
  static const primaryPadding = 15.0;
  static const secondaryPadding = 9.0;
  static const tertiaryPadding = 20.0;
  static const anotherPadding = 12.0;

  static const primaryBorderRadius = 8.0;
  static const secondaryBorderRadius = 5.68;
  static const tertiaryBorderRadius = 13.8;
  static const anotherBorderRadius = 12.2;

  static var textField = InputDecoration(
    errorStyle: CoreStyles.hint.copyWith(color: CoreColors.error),
    hintStyle: CoreStyles.hint,
    prefixStyle: CoreStyles.h4,
    labelStyle: CoreStyles.hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: secondaryPadding),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius), borderSide: BorderSide.none),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
        borderSide: const BorderSide(color: CoreColors.primary, width: 2)),
    fillColor: CoreColors.white,
    filled: true,
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
        borderSide: const BorderSide(color: CoreColors.error, width: 2)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
        borderSide: const BorderSide(color: CoreColors.errorFocused, width: 2)),
  );
}

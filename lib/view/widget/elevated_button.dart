import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/styles.dart';

class PrimaryElevatedButton extends StatelessWidget {
  const PrimaryElevatedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.disabled = false,
      this.loading = false,
      this.loadingText});
  final void Function()? onPressed;
  final String text;
  final bool loading;
  final bool disabled;
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: CoreColors.primary,
              elevation: 0),
          onPressed: disabled ? () {} : onPressed,
          child: Center(
            child: Text(
              loading ? loadingText ?? '•••' : text,
              style: CoreStyles.buttonTextOnPrimary,
            ),
          )),
    );
  }
}

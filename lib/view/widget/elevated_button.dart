import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/styles.dart';

class PrimaryElevatedButton extends StatelessWidget {
  const PrimaryElevatedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.textColor,
      this.disabled = false,
      this.loading = false,
      this.light = false,
      this.shape,
      this.icon,
      this.loadingText});
  final void Function()? onPressed;
  final String text;
  final Color? textColor;
  final bool loading;
  final bool disabled;
  final String? loadingText;
  final bool light;
  final IconData? icon;
  final RoundedRectangleBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: shape ??
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: light ? CoreColors.white : CoreColors.primary,
              elevation: 0),
          onPressed: disabled ? () {} : onPressed,
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 16,
                    color: light ? textColor ?? CoreColors.primary : CoreColors.white,
                  )
                : Text(
                    loading ? loadingText ?? '•••' : text,
                    style:
                        CoreStyles.buttonTextOnPrimary.copyWith(color: light ? textColor ?? CoreColors.primary : null),
                  ),
          )),
    );
  }
}

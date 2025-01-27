import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:get/get.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class DriverOrderRejectConfirmDialog extends StatelessWidget {
  const DriverOrderRejectConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
              child: Text("Отмена заказа".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          Padding(
              padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
              child: Text("Вы действительно хотите отказаться от заказа?".tr,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding, vertical: 5),
            child: PrimaryElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              light: true,
              text: 'Отказаться',
              textColor: CoreColors.error,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding, vertical: 5),
            child: PrimaryElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              light: true,
              text: 'Назад',
            ),
          ),
          SizedBox(height: CoreDecoration.primaryPadding)
        ],
      ),
    );
  }
}

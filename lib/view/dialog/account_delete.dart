import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:get/get.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class AccountDeleteConfirmDialog extends StatelessWidget {
  const AccountDeleteConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
              child: Text("Удаление акканута".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          Padding(
              padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
              child: Text(
                  "Вы действительно хотите удалить аккаунт? Все данные будут удалены без возможности восстановления".tr,
                      
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding, vertical: 5),
            child: PrimaryElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              light: true,
              text: 'Удалить аккаунт'.tr,
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
              text: 'Отмена'.tr,
            ),
          ),
          const SizedBox(height: CoreDecoration.primaryPadding)
        ],
      ),
    );
  }
}

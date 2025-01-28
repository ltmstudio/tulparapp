import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/icons.dart';
import 'package:tulpar/view/screen/driver/moderation.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class ModerationPreparationCard extends StatelessWidget {
  const ModerationPreparationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
      decoration: BoxDecoration(
        color: CoreColors.primary,
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Аккаунт TULPAR Водитель".tr,
            style: const TextStyle(fontSize: 18, color: CoreColors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            "Аккаунт водителя не найден. Заполните форму для выполнения заказов.".tr,
            style: const TextStyle(fontSize: 15, color: CoreColors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    TulparIcons.logo,
                    color: CoreColors.white,
                    size: 50,
                  ),
                ),
              ),
              Expanded(
                child: PrimaryElevatedButton(
                    light: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DriverModerationFormScreen()),
                      );
                    },
                    text: "Заполнить анкету".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}

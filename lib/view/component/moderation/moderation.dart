import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/icons.dart';

class ModerationModerationCard extends StatelessWidget {
  const ModerationModerationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
      decoration: BoxDecoration(
        color: CoreColors.moderationReviewStatus,
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
            "Анкета на модерации. Вы получите уведомление после изменения статуса".tr,
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
              GetBuilder<DriverModerationController>(builder: (moderationController) {
                var moderation = moderationController.moderation.value;
                if (moderation?.updatedAt == null) return Container();
                return Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Отправлено на модерацию:".tr,
                          textAlign: TextAlign.end, style: const TextStyle(color: CoreColors.white)),
                      Text(DateFormat('dd.MM.yyyy в HH:mm').format(moderation!.updatedAt!).tr,
                          textAlign: TextAlign.end,
                          style: const TextStyle(color: CoreColors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              })
            ],
          )
        ],
      ),
    );
  }
}

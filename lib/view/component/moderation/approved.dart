import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/icons.dart';

class ModerationApprovedCard extends StatelessWidget {
  const ModerationApprovedCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
      decoration: BoxDecoration(
        color: CoreColors.white,
        borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Аккаунт TULPAR Водитель".tr,
                  style: const TextStyle(fontSize: 18, color: CoreColors.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  "Статус: Подтвержден".tr,
                  style: const TextStyle(fontSize: 15, color: CoreColors.black, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(
            TulparIcons.logo,
            color: CoreColors.primary,
            size: 50,
          ),
        ],
      ),
    );
  }
}

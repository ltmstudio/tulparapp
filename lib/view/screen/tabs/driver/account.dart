import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/model/driver/moderation.dart';
import 'package:tulpar/view/component/moderation/approved.dart';
import 'package:tulpar/view/component/moderation/moderation.dart';
import 'package:tulpar/view/component/moderation/preparation.dart';
import 'package:tulpar/view/component/moderation/rejected.dart';

class DriverAccountTab extends StatefulWidget {
  const DriverAccountTab({super.key});

  @override
  State<DriverAccountTab> createState() => _DriverAccountTabState();
}

class _DriverAccountTabState extends State<DriverAccountTab> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(builder: (userController) {
      // var user = userController.user.value;
      return GetBuilder<DriverModerationController>(builder: (moderationController) {
        var moderation = moderationController.moderation.value;
        return Scaffold(
          appBar: AppBar(title: Text("Аккаунт водителя".tr)),
          body: RefreshIndicator(
            onRefresh: () async {
              await moderationController.fetchModeration();
            },
            child: ListView(
              padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
              children: [
                Builder(builder: (context) {
                  switch (moderation?.status) {
                    case DriverModerationStatus.preparation:
                      return const ModerationPreparationCard();
                    case DriverModerationStatus.moderation:
                      return const ModerationModerationCard();
                    case DriverModerationStatus.rejected:
                      return const ModerationRejectedCard();
                    case DriverModerationStatus.approved:
                      return const ModerationApprovedCard();
                    default:
                      return const ModerationPreparationCard();
                  }
                }),
                GetBuilder<AppController>(builder: (appController) {
                  var appMode = appController.appMode.value;
                  return ListTile(
                    onTap: () {
                      if (appMode == AppMode.user) {
                        appController.switchAppMode(AppMode.driver);
                      } else {
                        appController.switchAppMode(AppMode.user);
                      }
                    },
                    leading: const Icon(Icons.change_circle_outlined),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    title: Text("Перейти в режим клиента".tr),
                  );
                })
              ],
            ),
          ),
        );
      });
    });
  }
}

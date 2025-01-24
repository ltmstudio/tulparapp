import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/model/driver/moderation.dart';
import 'package:tulpar/view/component/moderation/approved.dart';
import 'package:tulpar/view/component/moderation/moderation.dart';
import 'package:tulpar/view/component/moderation/preparation.dart';
import 'package:tulpar/view/component/moderation/rejected.dart';
import 'package:tulpar/view/dialog/pay.dart';
import 'package:tulpar/view/screen/driver/info/info.dart';
import 'package:tulpar/view/screen/driver/shift.dart';

class DriverAccountTab extends StatefulWidget {
  const DriverAccountTab({super.key});

  @override
  State<DriverAccountTab> createState() => _DriverAccountTabState();
}

class _DriverAccountTabState extends State<DriverAccountTab> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverController>(builder: (driverController) {
      var profile = driverController.profile.value;
      return GetBuilder<DriverModerationController>(builder: (moderationController) {
        var moderation = moderationController.moderation.value;
        return Scaffold(
          appBar: AppBar(title: Text("Аккаунт водителя".tr)),
          body: RefreshIndicator(
            onRefresh: () async {
              await moderationController.fetchModeration();
              await driverController.fetchProfile();
            },
            child: ListView(
              padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
              children: [
                if (profile != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FocusedMenuHolder(
                          blurSize: 0.0,
                          menuItemExtent: 45,
                          animateMenuItems: false,
                          openWithTap: true,
                          menuBoxDecoration: const BoxDecoration(
                              color: CoreColors.white,
                              borderRadius: BorderRadius.all(Radius.circular(CoreDecoration.primaryBorderRadius))),
                          duration: const Duration(milliseconds: 30),
                          blurBackgroundColor: Colors.black54,
                          menuOffset: 5.0,
                          bottomOffsetHeight: 80.0,
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                                backgroundColor: Colors.transparent,
                                title: const Text("Открыть камеру"),
                                trailingIcon: const Icon(Icons.camera_alt_outlined, size: 16),
                                onPressed: () {
                                  driverController.pickNUploadPhoto(source: ImageSource.camera);
                                }),
                            FocusedMenuItem(
                                backgroundColor: Colors.transparent,
                                title: const Text("Открыть галерею"),
                                trailingIcon: const Icon(Icons.photo_library_outlined, size: 16),
                                onPressed: () {
                                  driverController.pickNUploadPhoto(source: ImageSource.gallery);
                                }),
                            if (profile.avatar != null)
                              FocusedMenuItem(
                                  backgroundColor: Colors.transparent,
                                  title: const Text("Удалить", style: TextStyle(color: CoreColors.delete)),
                                  trailingIcon:
                                      const Icon(Icons.delete_outline_outlined, size: 16, color: CoreColors.delete),
                                  onPressed: () {
                                    driverController.deleteAvatar();
                                  }),
                          ],
                          onPressed: () {},
                          child: Container(
                            width: 75,
                            height: 75,
                            margin: const EdgeInsets.only(right: CoreDecoration.primaryPadding),
                            child: Stack(
                              children: [
                                Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    color: CoreColors.lightGrey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: CoreColors.primary, width: 3),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(75),
                                    child: Builder(builder: (_) {
                                      var tempFile = driverController.tempFile.value;
                                      var tempFileLoading = driverController.tempFileLoading.value;
                                      if (tempFile != null) {
                                        return Image.file(
                                          File(tempFile.path),
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      if (profile.avatar != null) {
                                        return CachedNetworkImage(
                                          imageUrl: profile.avatarUrl,
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const Icon(Icons.person, size: 50, color: CoreColors.white);
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullname,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(children: [
                              if (profile.carName != null)
                                Text(
                                  "${profile.carName}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              if (profile.carNumber != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  margin: const EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: CoreColors.black, width: 1),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    "${profile.carNumber}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ]),
                            if (profile.carClass != null)
                              Text(
                                "Класс: ${profile.carClass!.name}",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ))
                      ],
                    ),
                  ),
                Builder(builder: (context) {
                  switch (moderation?.status) {
                    case DriverModerationStatus.preparation:
                      return const ModerationPreparationCard();
                    case DriverModerationStatus.moderation:
                      return const ModerationModerationCard();
                    case DriverModerationStatus.rejected:
                      return const ModerationRejectedCard();
                    case DriverModerationStatus.approved:
                      return ModerationApprovedCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "Текущий баланс: ${profile?.balance} ₸",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: profile?.level == null
                              ? null
                              : Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        color: profile?.level?.colorValue ?? CoreColors.grey, size: 20),
                                    Text("${profile?.level?.name}"),
                                  ],
                                ),
                          trailing: TextButton(
                              onPressed: () {
                                showModalBottomSheet(context: context, builder: (context) => PayDialog());
                              },
                              child: Text("Пополнить")),
                        ),
                      );
                    default:
                      return const ModerationPreparationCard();
                  }
                }),
                SizedBox(height: 15),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text("Справочник и FAQ"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const InfoAndFaqScreen()),
                    );
                  },
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DriverShiftScreen()));
                  },
                  leading: const Icon(Icons.timer_sharp),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  title: Text("Смены".tr),
                ),
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
                }),
              ],
            ),
          ),
        );
      });
    });
  }
}

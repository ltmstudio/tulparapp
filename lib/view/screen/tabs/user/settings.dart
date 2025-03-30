import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/view/dialog/account_delete.dart';
import 'package:tulpar/view/dialog/lang.dart';
import 'package:tulpar/view/dialog/logout.dart';
import 'package:tulpar/view/screen/app/log.dart';
import 'package:tulpar/view/screen/driver/info/info.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(builder: (userController) {
      var user = userController.user.value;
      return Scaffold(
        appBar: AppBar(
          title: Text("Настройки".tr),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text(user?.name ?? ''),
              subtitle: Text(user?.formattedTelephone ?? ""),
              trailing: const Icon(Icons.edit_rounded, color: CoreColors.primary),
              onTap: () {},
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: CoreColors.white),
                child: user?.letter != null
                    ? Center(
                        child: Text(
                        user!.letter,
                        style: CoreStyles.h3.copyWith(fontWeight: FontWeight.w700, color: CoreColors.primary),
                      ))
                    : Center(
                        child: Image.asset(CoreAssets.logoBlueTransparent, width: 30),
                      ),
              ),
            ),
            const Divider(),
            GetBuilder<AppController>(builder: (appController) {
              var lang = appController.locale.value;
              return ListTile(
                leading: const Icon(Icons.translate),
                title: Text("Язык".tr),
                trailing: lang.countryCode != null
                    ? Text(lang.countryCode.toString())
                    : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const LanguageDialog();
                      });
                },
              );
            }),
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
            GetBuilder<AppController>(builder: (appController) {
              return ListTile(
                onTap: () {
                  appController.switchAppMode(AppMode.driver);
                },
                leading: const Icon(Icons.change_circle_outlined),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                title: Text("Стать водителем".tr),
              );
            }),
            ListTile(
              onTap: () async {
                bool? confirmed = await showDialog(context: context, builder: (context) => const LogoutConfirmDialog());
                if (confirmed == true) {
                  Get.find<UserController>().logout();
                }
              },
              onLongPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogScreen()),
                );
              },
              leading: const Icon(
                Icons.logout_rounded,
                color: CoreColors.error,
              ),
              title: Text(
                "Выйти из аккаунта".tr,
                style: const TextStyle(color: CoreColors.error),
              ),
            ),
            ListTile(
              onTap: () async {
                bool? confirmed = await showDialog(context: context, builder: (context) => const AccountDeleteConfirmDialog());
                if (confirmed == true) {
                  Get.find<UserController>().logout();
                }
              },
              onLongPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogScreen()),
                );
              },
              leading: const Icon(
                Icons.person_remove_outlined,
                color: CoreColors.error,
              ),
              title: Text(
                "Удалить аккаунт".tr,
                style: const TextStyle(color: CoreColors.error),
              ),
            )
          ],
        ),
      );
    });
  }
}

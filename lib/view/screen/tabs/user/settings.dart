import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/icons.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/view/dialog/lang.dart';

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
                trailing: Text(appMode.name)
                // const Icon(Icons.arrow_forward_ios_rounded, size: 14)
                ,
                title: Text("Стать водителем".tr),
              );
            })
          ],
        ),
      );
    });
  }
}

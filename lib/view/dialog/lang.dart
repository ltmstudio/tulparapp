import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/decoration.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appController) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
                child: Text("Язык".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            for (var lang in AppController.supportedLocales)
              ListTile(
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      "${CoreAssets.images}/${lang.locale.countryCode}.png",
                      width: 40,
                    )),
                title: Text(lang.title),
                onTap: () {
                  Navigator.of(context).pop();
                  appController.switchLocale(lang.locale);
                },
              ),
            Padding(
              padding: const EdgeInsets.only(right: CoreDecoration.primaryPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Закрыть".tr))
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

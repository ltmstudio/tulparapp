import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/core/animation.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Image.asset(
                  CoreAssets.logoBlueTransparent,
                  width: 200,
                ),
              ),
              const Text(
                'TULPAR',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: CoreColors.primary),
              ),
              Text(
                'Сервис бронирования\nпопутного транспорта'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: GetBuilder<AppController>(builder: (controller) {
            var status = controller.appStatus.value;
            return AnimatedSwitcher(
              duration: CoreAnimations.d200,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: status == AppConnectionStatus.loading || status == AppConnectionStatus.done
                  ? Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: const LinearProgressIndicator(),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ошибка подключения к системе. Проверьте подключение к интернету и попробуйте заново".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          TextButton(onPressed: controller.initAppstatus, child: Text("Попробовать еще раз".tr))
                        ],
                      ),
                    ),
            );
          }),
        )
      ],
    ));
  }
}

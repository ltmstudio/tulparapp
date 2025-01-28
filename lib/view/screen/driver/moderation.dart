import 'package:flutter/material.dart';
import 'package:flutter_stepindicator/flutter_stepindicator.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class DriverModerationFormScreen extends StatefulWidget {
  const DriverModerationFormScreen({super.key});

  @override
  State<DriverModerationFormScreen> createState() => _DriverModerationFormScreenState();
}

class _DriverModerationFormScreenState extends State<DriverModerationFormScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DriverModerationController>().fetchModeration();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverModerationController>(builder: (moderationController) {
      var allScreens = moderationController.allScreens;
      var currentPage = moderationController.currentPage.value;
      return Scaffold(
        appBar: AppBar(title: Text("Анкета водителя".tr)),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: FlutterStepIndicator(
                      height: 28,
                      paddingLine: const EdgeInsets.symmetric(horizontal: 0),
                      positiveColor: CoreColors.primary,
                      progressColor: const Color(0xFFEA9C00),
                      negativeColor: const Color(0xFFD5D5D5),
                      padding: const EdgeInsets.all(4),
                      list: allScreens,
                      division: 1,
                      onChange: (i) {},
                      page: currentPage,
                      onClickItem: moderationController.goToPage,
                    ),
                  ),
                ),
                Expanded(child: allScreens[currentPage]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                  child: Row(
                    children: [
                      if (currentPage == 0)
                        Expanded(
                            child: PrimaryElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                light: true,
                                text: "Выйти".tr))
                      else
                        Expanded(
                            child: PrimaryElevatedButton(
                                onPressed: moderationController.previousPage, light: true, text: "Назад".tr)),
                      const SizedBox(width: 10),
                      if (currentPage == allScreens.length - 1)
                        Expanded(
                            child: PrimaryElevatedButton(
                                loading: moderationController.stageLoading.value,
                                onPressed: () async {
                                  var setted = await moderationController.setToModeration();
                                  if (setted && mounted) {
                                    CoreToast.showToast("Анкета отправлена на модерацию".tr);
                                    Navigator.of(context).pop();
                                  }
                                },
                                text: "Подтвердить".tr))
                      else
                        Expanded(
                            child: PrimaryElevatedButton(
                                loading: moderationController.stageLoading.value,
                                onPressed: () async {
                                  var validated = await moderationController.validateStage();
                                  if (validated) {
                                    moderationController.nextPage();
                                  }
                                },
                                text: "Далее".tr)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
